let
  grafanaPort = 3000;
  buildGrafanaInfluxSource = db: {
    name = "Influx-${db} DB";
    type = "influxdb";
    database = db;
    url = "http://127.0.0.1:8086";
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

      networking.firewall.allowedTCPPorts = [ 80 grafanaPort ];
    };
}
