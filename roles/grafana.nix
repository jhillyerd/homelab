{ config, pkgs, lib, ... }:
let
  influxdbHost = "127.0.0.1";
  influxdbPort = 8086;
  telegrafDbName = "telegraf";
  buildGrafanaInfluxSource = db: {
    name = "${db}-influxdb";
    type = "influxdb";
    database = db;
    url = "http://${influxdbHost}:${toString influxdbPort}";
    isDefault = db == telegrafDbName;
  };
in
{
  services.grafana = {
    enable = true;
    addr = "";
    port = 3000;
    domain = "webserver.skynet.local";
    provision = {
      enable = true;
      datasources = map buildGrafanaInfluxSource [ telegrafDbName ];
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.grafana.port ];
}
