{
  network.description = "Home Services";

  defaults =
    { config, pkgs, lib, nodes, ... }:
    let
      influxHost = "nexus";
      influxPort = nodes.nexus.config.roles.influxdb.port;
    in
    {
      imports = [ ./common.nix ./roles ];

      roles.telegraf = {
        enable = true;
        influxDbUrl = "http://${influxHost}:${toString influxPort}";
        influxDbName = "telegraf-hosts";
      };
  };

  nexus =
    { config, pkgs, lib, ... }:
    {
      roles.grafana = {
        enable = true;
        domain = "nexus.skynet.local";
        datasources = [
          { name = config.roles.telegraf.influxDbName; type = "influxdb"; }
        ];
      };

      roles.influxdb.enable = true;
    };

  webserver =
    { nodes, config, pkgs, lib, ... }:
    let
      mypkgs = import ./pkgs { nixpkgs = pkgs; };
    in with mypkgs;
    {
      services.nginx.enable = true;
      services.nginx.virtualHosts."127.0.0.1" = {
        root = "${website}";
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
