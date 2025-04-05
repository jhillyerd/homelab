{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.roles.gui-wayland;
in
{
  options.roles.gui-wayland = {
    enable = mkEnableOption "Wayland GUI";
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
        audacity
        clipman
        dunst
        firefox
        gedit
        gimp
        google-chrome
        i3-balance-workspace
        libnotify # for notify-send
        lxappearance
        obs-studio
        pantheon.elementary-icon-theme
        pavucontrol
        rofi-wayland
        slurp # region selector
        virt-manager
        wl-clipboard # clipboard commands
        xfce.ristretto # image viwer
        yambar
      ])
      ++ remaps;

    programs.dconf.enable = true;

    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-volman ];
    };

    programs.sway = {
      enable = true;
      extraOptions = [ "--unsupported-gpu" ];
    };

    services.xserver.displayManager.gdm.enable = true;

    # Used by thunar.
    services.gvfs.enable = true;
    services.tumbler.enable = true;

    services.libinput.enable = true;
    services.libinput.mouse.accelProfile = "flat";

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
