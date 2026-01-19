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
  };
}
