{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.grafana;

  mkGrafanaSource = ds: {
    name = "${ds.name} ${ds.type}";
    type = ds.type;
    database = ds.name;
    url = "http://localhost:${toString config.roles.influxdb.port}";
  };
in
{
  options.roles.grafana = {
    enable = mkEnableOption "Network Grafana host";

    domain = mkOption {
      type = types.str;
      example = "example.com";
      description = "Domain name";
    };

    port = mkOption {
      type = types.port;
      description = "Web interface port";
      default = 3000;
    };

    datasources = mkOption {
      type = with types; listOf (submodule {
        options = {
          name = mkOption {
            type = str;
          };
          type = mkOption {
            type = enum [ "influxdb" ];
          };
        };
      });
      description = "Grafana datasources";
      default = [];
    };
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      addr = "";
      port = cfg.port;
      domain = cfg.domain;
      provision = mkIf ((builtins.length cfg.datasources) > 0) {
        enable = true;
        datasources = map mkGrafanaSource cfg.datasources;
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
