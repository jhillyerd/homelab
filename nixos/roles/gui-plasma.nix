{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.roles.gui-plasma;
in
{
  options.roles.gui-plasma = {
    enable = mkEnableOption "KDE Plasma GUI";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      let
        remaps = [
          (pkgs.writeShellScriptBin "x-www-browser" ''
            exec ${pkgs.firefox}/bin/firefox "$@"
          '')
        ];
      in
      (with pkgs; [
        alsa-utils
        audacity
        clipman
        firefox
        gimp
        libnotify
        obs-studio
        pavucontrol
        slurp
        ungoogled-chromium
        virt-manager
      ])
      ++ remaps;

    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "james" ];
    };

    programs.dconf.enable = true;

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
    services.desktopManager.plasma6.enable = true;

    services.libinput.enable = true;
    services.libinput.mouse.accelProfile = "flat";

    fonts.packages = with pkgs; [
      font-awesome
      fira-code
      inconsolata
      noto-fonts
      terminus_font
    ];

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

    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
