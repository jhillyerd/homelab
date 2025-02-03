{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.roles.gui-xorg;
in
{
  options.roles.gui-xorg = {
    enable = mkEnableOption "Xorg GUI";
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
        dmenu
        dunst
        firefox
        gedit
        gimp
        google-chrome
        i3-balance-workspace
        libnotify # for notify-send
        lxappearance
        maim # takes screenshots
        obs-studio
        pantheon.elementary-icon-theme
        polybarFull
        pavucontrol
        rofi
        rxvt-unicode
        sxhkd
        virt-manager
        xclip
        xfce.ristretto # image viwer
        xorg.xdpyinfo
        xorg.xev
        xsecurelock
        xss-lock
      ])
      ++ remaps;

    programs.dconf.enable = true;

    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-volman ];
    };

    # Used by thunar.
    services.gvfs.enable = true;
    services.tumbler.enable = true;

    services.xserver = {
      enable = true;
      xkb.layout = "us";

      windowManager.i3.enable = true;
    };

    services.libinput.enable = true;
    services.libinput.mouse.accelProfile = "flat";

    fonts.packages = with pkgs; [
      fira-code
      inconsolata
      noto-fonts
      siji
      terminus_font
      unifont
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

    # Mouse button mappings.
    environment.etc."X11/xorg.conf.d/99-mouse-buttons.conf".text = ''
      Section "InputClass"
        Identifier "SONiX Evoluent VerticalMouse D"
        Option "ButtonMapping" "1 2 3 4 5 6 7 10 9 8"
      EndSection
    '';
  };
}
