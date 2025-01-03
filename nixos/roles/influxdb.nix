{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    ;
  inherit (lib.types)
    attrsOf
    path
    port
    str
    submodule
    ;
  cfg = config.roles.influxdb;
in
{
  options.roles.influxdb = {
    enable = mkEnableOption "Enable InfluxDB role";

    port = mkOption {
      type = port;
      description = "API port. Do not change, for reference only";
      default = 8086;
    };

    adminUser = mkOption {
      type = str;
      description = "Database admin username";
      default = "admin";
    };

    adminPasswordFile = mkOption {
      type = path;
      description = "Database admin password file";
    };

    databases = mkOption {
      type = attrsOf (submodule {
        options = {
          user = mkOption { type = str; };
          passwordFile = mkOption { type = str; };
          retention = mkOption {
            type = str;
            default = "104w";
          };
        };
      });
      description = "Influx databases";
      default = { };
    };
  };

  config =
    let
      createDb = name: db: ''
        CREATE DATABASE "${name}";
        CREATE USER "${db.user}" WITH PASSWORD '$(< ${db.passwordFile})';
        GRANT ALL ON "${name}" TO "${db.user}";
        ALTER RETENTION POLICY "autogen" ON "${name}" DURATION ${db.retention};
      '';

      initSql = lib.concatStringsSep "\n" (mapAttrsToList createDb cfg.databases);
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
          export INFLUX_PASSWORD="$(< ${cfg.adminPasswordFile})"
          lockfile=/var/db/influxdb-init-completed
          set -eo pipefail

          if [ -f "$lockfile" ]; then
            exit
          fi

          touch "$lockfile"
          ${pkgs.influxdb}/bin/influx <<ENDCREATEADMIN
          CREATE USER "$INFLUX_USERNAME" WITH PASSWORD '$INFLUX_PASSWORD' WITH ALL PRIVILEGES;
          ENDCREATEADMIN

          ${pkgs.influxdb}/bin/influx <<ENDCREATEUSERDATABASES
          ${initSql}
          ENDCREATEUSERDATABASES
        '';
      };

      networking.firewall.allowedTCPPorts = [ cfg.port ];
    };
}
