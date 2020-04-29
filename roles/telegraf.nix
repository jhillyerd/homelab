{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.telegraf;
in
{
  options.roles.telegraf = {
    enable = mkEnableOption "Telegraf node";

    influxDbUrl = mkOption {
      type = types.str;
      description = "InfluxDB URL";
    };

    influxDbName = mkOption {
      type = types.str;
      description = "InfluxDB Database Name";
    };
  };

  config = mkIf cfg.enable {
    services.telegraf = {
      enable = true;
      extraConfig = {
        inputs = {
          cpu = { percpu = true; };
          disk = {};
          kernel = {};
          mem = {};
          net = {};
          netstat = {};
          swap = {};
          system = {};
        };

        outputs.influxdb = {
          database = cfg.influxDbName;
          urls = [ cfg.influxDbUrl ];
        };
      };
    };
  };
}
