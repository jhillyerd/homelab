{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.roles.gui-common;
in
{
  options.roles.gui-common = {
    enable = mkEnableOption "Common to all GUI roles";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alsa-utils
      audacity
      firefox
      gimp
      libnotify # for notify-send
      obs-studio
      pavucontrol
      ungoogled-chromium
      virt-manager
    ];

    programs.dconf.enable = true;

    programs._1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ "james" ];
    };

    services.libinput.enable = true;
    services.libinput.mouse.accelProfile = "flat";

    services.syncthing = {
      enable = true;
      user = "james";
      dataDir = "/home/james";
    };
    users.users.james.extraGroups = [ "syncthing" ];

    fonts.packages = with pkgs; [
      font-awesome
      fira-code
      inconsolata
      noto-fonts
      terminus_font
    ];

    # Sound.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Bluetooth.
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;

    # Printer support.
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
