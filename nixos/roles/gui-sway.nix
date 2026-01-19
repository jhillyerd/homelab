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

    programs._1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ "james" ];
    };

    programs.dconf.enable = true;

    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-volman ];
    };

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraOptions = [ "--unsupported-gpu" ];
    };

    services.greetd = {
      enable = true;
      useTextGreeter = true;

      settings = {
        default_session = {
          command = pkgs.writeShellScript "start-tuigreet" ''
            setterm --blank=10
            setterm --powersave on
            ${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session
          '';
          user = "greeter";
        };
      };
    };

    # Used by thunar.
    services.gvfs.enable = true;
    services.tumbler.enable = true;

    services.gnome.gnome-keyring.enable = true;
    services.gnome.gcr-ssh-agent.enable = false;
    services.libinput.enable = true;
    services.libinput.mouse.accelProfile = "flat";

    services.xserver.displayManager.sessionCommands = ''
      # this is needed for gnome-keyring to work properly
      ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all

      # this is needed for xdg-desktop-portal to work
      systemctl --user import-environment PATH DISPLAY XAUTHORITY DESKTOP_SESSION \
        XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_SESSION_ID \
        DBUS_SESSION_BUS_ADDRESS || true
    '';

    fonts.packages = with pkgs; [
      font-awesome
      fira-code
      inconsolata
      noto-fonts
      terminus_font
    ];

    # Enable sound.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;

    # IPP Printer support.
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
