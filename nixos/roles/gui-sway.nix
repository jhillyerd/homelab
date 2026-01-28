{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.roles.gui-sway;
in
{
  options.roles.gui-sway = {
    enable = mkEnableOption "Wayland GUI";
  };

  config = mkIf cfg.enable {
    roles.gui-common.enable = true;

    environment.systemPackages = with pkgs; [
      clipman
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
      xfce.ristretto # image viwer
      yambar
    ];

    # Enable Ozone Wayland support in Chromium and Electron based applications
    # Still breaks camera in Chrome.
    # environment.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-volman ];
    };

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraOptions = [ "--unsupported-gpu" ];
    };

    # Used by thunar.
    services.gvfs.enable = true;
    services.tumbler.enable = true;

    services.gnome.gnome-keyring.enable = true;
    services.gnome.gcr-ssh-agent.enable = false;

    services.xserver.displayManager.sessionCommands = ''
      # this is needed for gnome-keyring to work properly
      ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all

      # this is needed for xdg-desktop-portal to work
      systemctl --user import-environment PATH DISPLAY XAUTHORITY DESKTOP_SESSION \
        XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_SESSION_ID \
        DBUS_SESSION_BUS_ADDRESS || true
    '';
  };
}
