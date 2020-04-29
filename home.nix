{
  network.description = "Home Services";

  defaults = {
    imports = [ ./common.nix ];
  };

  nexus =
    { config, pkgs, lib, ... }:
    {
      imports = [
        ./roles/grafana.nix
        ./roles/influxdb.nix
      ];

      roles.grafana = {
        enable = true;
        domain = "nexus.skynet.local";
      };

      roles.influxdb.enable = true;
    };

  webserver =
    { nodes, config, pkgs, lib, ... }:
    let
      mypkgs = import ./pkgs { nixpkgs = pkgs; };
      influxdbPort = 8086;
      telegrafDbName = "telegraf";
    in with mypkgs;
    {
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
            urls = [ "http://nexus:${toString influxdbPort}" ];
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
