{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.roles.upsmon;
in
{
  options.roles.upsmon = {
    enable = lib.mkEnableOption "Monitor remote UPS status and shutdown after a delay";

    wave = lib.mkOption {
      description = "Shutdown ordering, lower values shutdown earlier";
      type = lib.types.enum [
        1
        2
        3
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    power.ups =
      let
        wave = {
          "1" = 120;
          "2" = 180;
          "3" = 240;
        };

        secret = pkgs.writeText "upsmon" "secret";

        rules = pkgs.writeText "upssched" ''
          CMDSCRIPT ${../roles/files/nut/upssched-cmd}
          PIPEFN /etc/nut/upssched.pipe
          LOCKFN /etc/nut/upssched.lock

          AT ONBATT * START-TIMER onbatt 15
          AT ONLINE * CANCEL-TIMER onbatt online
          AT ONBATT * START-TIMER earlyshutdown ${toString wave."${toString cfg.wave}"}
          AT ONLINE * CANCEL-TIMER earlyshutdown online
          AT LOWBATT * EXECUTE onbatt
          AT COMMBAD * START-TIMER commbad 30
          AT COMMOK * CANCEL-TIMER commbad commok
          AT NOCOMM * EXECUTE commbad
          AT SHUTDOWN * EXECUTE powerdown
          AT SHUTDOWN * EXECUTE powerdown
        '';
      in
      {
        enable = true;
        mode = "netclient";
        schedulerRules = "${rules}";

        upsmon.settings = {
          NOTIFYFLAG = [
            [
              "ONLINE"
              "SYSLOG+EXEC"
            ]
            [
              "ONBATT"
              "SYSLOG+EXEC"
            ]
            [
              "LOWBATT"
              "SYSLOG+EXEC"
            ]
          ];
        };

        upsmon.monitor.mininas = {
          system = "ups@mininas.home.arpa";
          type = "secondary";
          user = "monuser";
          passwordFile = "${secret}";
        };
      };
  };
}
