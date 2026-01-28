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
    roles.gui-common.enable = true;

    environment.systemPackages = with pkgs; [
      clipman
      slurp
    ];

    services.desktopManager.plasma6.enable = true;
  };
}
