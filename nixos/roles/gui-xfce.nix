{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.roles.gui-xfce;
in
{
  options.roles.gui-xfce = {
    enable = mkEnableOption "Xfce GUI";
  };

  config = mkIf cfg.enable {
    roles.gui-common.enable = true;

    environment.systemPackages = with pkgs; [
      dmenu
      dunst
      gedit
      lxappearance
      maim # takes screenshots
      pantheon.elementary-icon-theme
      rofi
      rxvt-unicode
      sxhkd
      xclip
      xorg.xdpyinfo
      xorg.xinit
      xorg.xev
    ];

    programs.thunar.plugins = [ pkgs.xfce.thunar-volman ];

    services.xserver = {
      enable = true;
      xkb.layout = "us";
      desktopManager = {
        xfce.enable = true;
        xterm.enable = false;
      };
    };
    services.displayManager.defaultSession = "xfce";

    # Mouse button mappings.
    environment.etc."X11/xorg.conf.d/99-mouse-buttons.conf".text = ''
      Section "InputClass"
        Identifier "SONiX Evoluent VerticalMouse D"
        Option "ButtonMapping" "1 2 3 4 5 6 7 10 9 8"
      EndSection
    '';
  };
}
