{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.influxdb;
in
{
  options.roles.influxdb = {
    enable = mkEnableOption "Enable InfluxDB role";

    port = mkOption {
      type = types.port;
      description = "API port. Do not change, for reference only";
      default = 8086;
    };
  };

  config =
    let
      init-sql = pkgs.writeText "influxdb-init.sql"
        ''
          CREATE USER admin WITH PASSWORD 'foobar' WITH ALL PRIVILEGES;
        '';
    in
    mkIf cfg.enable {
      environment.systemPackages = [ pkgs.influxdb ]; # for diagnostics

      services.influxdb.enable = true;

      systemd.services.influxdb-init = {
        enable = true;
        description = "Configure influxdb at first boot";
        wantedBy = [ "multi-user.target" ];
        after = [ "influxdb.service" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        script = ''
          lockfile=/var/db/influxdb-init-completed
          set -eo pipefail

          if [ ! -f "$lockfile" ]; then
            touch "$lockfile"
            ${pkgs.influxdb}/bin/influx < ${init-sql}
          fi
        '';
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    };
}
