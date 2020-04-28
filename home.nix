let
  grafanaPort = 3000;
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
  network.description = "Home Services";

  webserver =
    { config, pkgs, lib, ... }:
    let
      mypkgs = import ./pkgs { nixpkgs = pkgs; };
    in with mypkgs;
    {
      environment.systemPackages = [ pkgs.influxdb ];

      services.grafana = {
        enable = true;
        addr = "";
        port = grafanaPort;
        domain = "webserver.skynet.local";
        provision = {
          enable = true;
          datasources = map buildGrafanaInfluxSource [ telegrafDbName ];
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
            database = telegrafDbName;
            urls = [ "http://${influxdbHost}:${toString influxdbPort}" ];
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 80 grafanaPort ];
    };
}
