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
  };
}
