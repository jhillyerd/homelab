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
      nixpkgs.overlays = [ (super: self: {
        website = super.callPackage ./pkgs/website {};
        open-sans-webfont = super.callPackage ./pkgs/open-sans-webfont {};
      }) ];

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
    {
      services.nginx.enable = true;
      services.nginx.virtualHosts."127.0.0.1" = {
        root = "${pkgs.website}";
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
