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
    roles.gui-common.enable = true;

    environment.systemPackages = with pkgs; [
      dmenu
      dunst
      gedit
      i3-balance-workspace
      lxappearance
      maim # takes screenshots
      pantheon.elementary-icon-theme
      polybarFull
      rofi
      rxvt-unicode
      sxhkd
      xclip
      xfce.ristretto # image viwer
      xorg.xdpyinfo
      xorg.xev
      xsecurelock
      xss-lock
    ];

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

    fonts.packages = with pkgs; [
      siji
    ];

    # Mouse button mappings.
    environment.etc."X11/xorg.conf.d/99-mouse-buttons.conf".text = ''
      Section "InputClass"
        Identifier "SONiX Evoluent VerticalMouse D"
        Option "ButtonMapping" "1 2 3 4 5 6 7 10 9 8"
      EndSection
    '';
  };
}
