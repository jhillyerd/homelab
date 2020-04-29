{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.influxdb;
in
{
  options.roles.influxdb = {
    enable = mkEnableOption "Network InfluxDB host";

    port = mkOption {
      type = types.port;
      description = "API port. Do not change, for reference only";
      default = 8086;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.influxdb ]; # for diagnostics

    services.influxdb.enable = true;

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
