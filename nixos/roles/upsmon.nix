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
    enable = lib.mkEnableOption "Enable NFS mount of catalog cluster volumes";

    onBattSeconds = lib.mkOption {
      description = "Shutdown after running on battery for specified time";
      type = lib.types.int;
      default = 180;
    };
  };

  config = lib.mkIf cfg.enable {
    power.ups =
      let
        secret = pkgs.writeText "upsmon" "secret";

        rules = pkgs.writeText "upssched" ''
          CMDSCRIPT ${../roles/files/nut/upssched-cmd}
          PIPEFN /etc/nut/upssched.pipe
          LOCKFN /etc/nut/upssched.lock

          AT ONBATT * START-TIMER onbatt 15
          AT ONLINE * CANCEL-TIMER onbatt online
          AT ONBATT * START-TIMER earlyshutdown ${toString cfg.onBattSeconds}
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

        upsmon.monitor.skynas = {
          system = "ups@witness.home.arpa";
          type = "secondary";
          user = "monuser";
          passwordFile = "${secret}";
        };
      };
  };
}
