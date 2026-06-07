{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.roles.gui-sway;

  polkit-agent-script = pkgs.writeShellApplication {
    name = "polkit-agent-script";
    runtimeInputs = with pkgs; [
      jq
      libnotify
      rofi
    ];
    text = builtins.readFile ./files/gui/polkit-agent-script.sh;
  };
in
{
  options.roles.gui-sway = {
    enable = mkEnableOption "Sway GUI";
  };

  config = mkIf cfg.enable {
    roles.gui-common.enable = true;

    environment.systemPackages = with pkgs; [
      clipman
      cmd-polkit
      dunst
      gcr # gnome keyring SystemPrompter
      gedit
      i3-balance-workspace
      lxappearance
      pantheon.elementary-icon-theme
      rofi
      seahorse # secret management
      slurp # region selector
      wl-clipboard # clipboard commands
      ristretto # image viwer
      yambar
    ];

    # Enable Ozone Wayland support in Chromium and Electron based applications
    # Still breaks camera in Chrome.
    # environment.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.thunar = {
      enable = true;
      plugins = with pkgs; [ thunar-volman ];
    };

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraOptions = [ "--unsupported-gpu" ];
      extraSessionCommands = ''
        # Import environment into systemd user session and D-Bus activation
        # environment. This is needed for gnome-keyring, xdg-desktop-portal,
        # and polkit agents to work properly.
        ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
      '';
    };

    # Polkit authentication agent.
    # We use cmd-polkit instead of soteria because cmd-polkit spawns the
    # PAM helper immediately and forwards PAM messages (like pam_u2f's
    # "please touch" cue) in real time, allowing touch-only auth without
    # a password prompt.
    security.polkit.enable = true;

    systemd.user.services.polkit-cmd-polkit = {
      description = "cmd-polkit authentication agent";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = ''
          ${lib.getExe pkgs.cmd-polkit} --serial --command ${lib.getExe polkit-agent-script}
        '';
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    # Used by thunar.
    services.gvfs.enable = true;
    services.tumbler.enable = true;

    services.gnome.gnome-keyring.enable = true;
    services.gnome.gcr-ssh-agent.enable = false;
  };
}
