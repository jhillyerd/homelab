# Polkit authentication handler for cmd-polkit-agent.
#
# Communicates via JSON on stdin/stdout. Shows a notification for touch
# prompts (pam_u2f "cue" messages) and only opens a rofi password dialog
# when PAM actually requests a password.

log() { echo "polkit-agent-script: $*" >&2; }

notify_id=""

dismiss_notification() {
  if [[ -n "$notify_id" ]]; then
    # CloseNotification is the freedesktop.org notification-spec mechanism for
    # immediate dismissal. Re-sending an expired replacement only happened to
    # work with Dunst; Noctalia assigns its own notification IDs.
    dbus-send --session \
      --dest=org.freedesktop.Notifications \
      --type=method_call \
      /org/freedesktop/Notifications \
      org.freedesktop.Notifications.CloseNotification \
      "uint32:$notify_id" >/dev/null 2>&1 || true
    notify_id=""
  fi
}

show_notification() {
  local text="$1"
  local icon="${2:-dialog-information}"
  local new_notify_id

  # Keep the ID returned by the server: replacement IDs are assigned by the
  # notification daemon, rather than by clients. --print-id makes this work
  # with both Noctalia and Dunst.
  new_notify_id=$(notify-send \
    --print-id \
    --replace-id="${notify_id:-0}" \
    --expire-time=30000 \
    --icon="$icon" \
    "Authentication" \
    "$text" 2>/dev/null) || true
  if [[ "$new_notify_id" =~ ^[0-9]+$ ]]; then
    notify_id="$new_notify_id"
  fi
}

cleanup() {
  dismiss_notification
}
trap cleanup EXIT

log "started, waiting for input"

# Show touch prompt immediately — if a U2F key is present, pam_u2f will be the
# first module in the PAM stack and will wait for a touch. We show the
# notification proactively because cmd-polkit may not deliver the PAM_TEXT_INFO
# "show info" message to us in time (race with the GLib main loop).
show_notification "Please touch the FIDO authenticator." "dialog-information"

while IFS= read -r line; do
  log "received: $line"
  action=$(echo "$line" | jq -r '.action // empty' 2>/dev/null) || continue

  case "$action" in
    "show info")
      text=$(echo "$line" | jq -r '.text // ""')
      log "show info: $text"
      show_notification "$text" "dialog-information"
      ;;

    "show error")
      text=$(echo "$line" | jq -r '.text // ""')
      log "show error: $text"
      show_notification "$text" "dialog-error"
      ;;

    "request password")
      dismiss_notification
      prompt=$(echo "$line" | jq -r '.prompt // "Password: "')
      message=$(echo "$line" | jq -r '.message // "Authentication required"')

      # Open rofi in password mode for the fallback password prompt.
      password=$(rofi -password -dmenu -no-fixed-num-lines \
        -p "$prompt" \
        -mesg "$message" 2>/dev/null) || true

      if [[ -z "$password" ]]; then
        echo '{"action": "cancel"}'
        exit 0
      else
        # Escape the password for JSON.
        escaped=$(jq -n --arg pw "$password" '$pw')
        echo "{\"action\": \"authenticate\", \"password\": $escaped}"
      fi
      ;;

    "authorization response")
      authorized=$(echo "$line" | jq -r '.authorized // false')
      log "authorization response: authorized=$authorized"
      if [[ "$authorized" == "true" ]]; then
        dismiss_notification
        exit 0
      else
        show_notification "Authentication failed" "dialog-error"
      fi
      ;;
  esac
done
