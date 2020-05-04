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

      # TODO this role may not be necessary if default telegraf is good enough.
      roles.telegraf = {
        enable = true;
        influxDbUrl = "http://${influxHost}:${toString influxPort}";
        influxDbName = "telegraf-hosts";
        influxDbUser = lowsec.influxdb.telegraf.user;
        influxDbPassword = lowsec.influxdb.telegraf.password;
      };
  };

  nexus =
    { config, pkgs, lib, ... }:
    let
      # Construct a grafana datasource from our influxdb database.
      mkGrafanaInfluxSource = name: db: {
        name = "${name} influxdb";
        type = "influxdb";
        database = name;
        # TODO don't use localhost.
        url = "http://localhost:${toString config.roles.influxdb.port}";
        user = db.user;
        password = db.password;
      };
    in
    {
      roles.grafana = {
        enable = true;
        domain = "nexus.skynet.local";
        datasources = lib.mapAttrsToList mkGrafanaInfluxSource config.roles.influxdb.databases;
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
