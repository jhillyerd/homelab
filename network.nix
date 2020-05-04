let
  # Import low security credentials.
  lowsec = import ./lowsec.nix;
in
{
  network.description = "Home Services";

  defaults =
    { pkgs, nodes, ... }:
    let
      influxHost = "nexus";
      influxPort = nodes.nexus.config.roles.influxdb.port;
    in
    {
      imports = [ ./common.nix ./roles ];
      nixpkgs.overlays = [ (import ./pkgs/overlay.nix) ];

      roles.telegraf = {
        enable = true;
        influxDbUrl = "http://${influxHost}:${toString influxPort}";
        influxDbName = "telegraf-hosts";
      };
  };

  nexus =
    { config, pkgs, ... }:
    {
      roles.grafana = {
        enable = true;
        domain = "nexus.skynet.local";
        datasources = [
          { name = config.roles.telegraf.influxDbName; type = "influxdb"; }
        ];
      };

      roles.influxdb = {
        enable = true;
        adminUser = lowsec.influxdb.admin.user;
        adminPassword = lowsec.influxdb.admin.password;

        databases = {
          telegraf-hosts = {
            user = lowsec.influxdb.telegraf.user;
            password = lowsec.influxdb.telegraf.password;
          };
        };
      };

      # webserver
      services.nginx.enable = true;
      services.nginx.virtualHosts."127.0.0.1" = {
        root = "${pkgs.website}";
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
