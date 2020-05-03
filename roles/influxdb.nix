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

    adminUser = mkOption {
      type = types.str;
      description = "Database admin username";
      default = "admin";
    };

    adminPassword = mkOption {
      type = types.str;
      description = "Database admin password";
      default = "admin";
    };

    databases = mkOption {
      type = with types; attrsOf (submodule {
        options = {
          user = mkOption {
            type = str;
          };
          password = mkOption {
            type = str;
          };
        };
      });
      description = "Influx databases";
      default = {};
    };
  };

  config =
    let
      createAdmin = pkgs.writeText "influxdb-admin.sql"
        ''
          CREATE USER "${cfg.adminUser}" WITH PASSWORD '${cfg.adminPassword}' WITH ALL PRIVILEGES;
        '';

      createDb = name: db:
        ''
          CREATE DATABASE "${name}";
          CREATE USER "${db.user}" WITH PASSWORD '${db.password}';
          GRANT ALL ON "${name}" TO "${db.user}";
        '';

      initSql = pkgs.writeText "influxdb-init.sql"
        (lib.concatStringsSep "\n" (mapAttrsToList createDb cfg.databases));
    in
    mkIf cfg.enable {
      environment.systemPackages = [ pkgs.influxdb ]; # for diagnostics

      services.influxdb = {
        enable = true;
        extraConfig.http.auth-enabled = true;
      };

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
          export INFLUX_USERNAME=${lib.escapeShellArg cfg.adminUser}
          export INFLUX_PASSWORD=${lib.escapeShellArg cfg.adminPassword}
          lockfile=/var/db/influxdb-init-completed
          set -eo pipefail

          if [ ! -f "$lockfile" ]; then
            touch "$lockfile"
            ${pkgs.influxdb}/bin/influx < ${createAdmin}
            ${pkgs.influxdb}/bin/influx < ${initSql}
          fi
        '';
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    };
}
