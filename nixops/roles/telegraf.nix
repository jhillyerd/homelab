{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.telegraf;
in
{
  options.roles.telegraf = {
    enable = mkEnableOption "Telegraf node";

    influxdb = mkOption {
      type = types.attrs;
      description = "Influxdb output options";
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

        outputs.influxdb = cfg.influxdb;
      };
    };
  };
}
