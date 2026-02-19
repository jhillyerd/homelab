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
    enable = mkEnableOption "Sway GUI";
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
      extraSessionCommands = ''
        # Import environment into systemd user session and D-Bus activation
        # environment. This is needed for gnome-keyring, xdg-desktop-portal,
        # and polkit agents (soteria) to work properly.
        ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
      '';
    };

    # Polkit authentication agent.
    security.soteria.enable = true;

    # Used by thunar.
    services.gvfs.enable = true;
    services.tumbler.enable = true;

    services.gnome.gnome-keyring.enable = true;
    services.gnome.gcr-ssh-agent.enable = false;
  };
}
