{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.grafana;
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
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      addr = "";
      port = cfg.port;
      domain = cfg.domain;
      # provision = {
      #   enable = true;
      #   datasources = map buildGrafanaInfluxSource [ telegrafDbName ];
      # };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
