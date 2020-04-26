let
  grafanaPort = 3000;
  influxdbHost = "127.0.0.1";
  influxdbPort = 8086;
  buildGrafanaInfluxSource = db: {
    name = "Influx-${db} DB";
    type = "influxdb";
    database = db;
    url = "http://${influxdbHost}:${toString influxdbPort}";
  };
in
{
  network.description = "Home Services";

  webserver =
    { config, pkgs, lib, ... }:
    let
      mypkgs = import ./pkgs { nixpkgs = pkgs; };
    in with mypkgs;
    {
      services.grafana = {
        enable = true;
        addr = "";
        port = grafanaPort;
        domain = "webserver.skynet.local";
        provision = {
          enable = true;
          datasources = map buildGrafanaInfluxSource [ "home" ];
        };
      };

      services.influxdb.enable = true;

      services.nginx.enable = true;
      services.nginx.virtualHosts."127.0.0.1" = {
        root = "${website}";
      };

      services.telegraf = {
        enable = true;
        extraConfig = {
          inputs = {
            cpu = {};
            disk = {};
            kernel = {};
            mem = {};
            net = {};
            netstat = {};
            swap = {};
            system = {};
          };

          outputs.influxdb = {
            database = "telegraf";
            urls = [ "http://${influxdbHost}:${toString influxdbPort}" ];
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 80 grafanaPort ];
    };
}
