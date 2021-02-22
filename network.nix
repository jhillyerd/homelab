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
        influxdb = {
          urls = [ "http://${influxHost}:${toString influxPort}" ];
          database = "telegraf-hosts";
          username = lowsec.influxdb.telegraf.user;
          password = lowsec.influxdb.telegraf.password;
        };
      };
    };

  nexus =
    { config, pkgs, lib, nodes, resources, ... }:
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

      roles.mosquitto = {
        enable = true;

        users = {
          admin = {
            password = lowsec.mqtt.admin.password;
            acl = [ "topic $SYS/#" "topic #" ];
          };
          sensor = {
            password = lowsec.mqtt.sensor.password;
            acl = [];
          };
        };
      };

      roles.homesite = {
        enable = true;
        services = [
          {
            name = "Grafana";
            # host = resources.machines.nexus.networking.privateIPv4;
            host = "nexus";
            port = nodes.nexus.config.roles.grafana.port;
            proto = "http";
            icon = "chart-area";
          }
          {
            name = "OctoPrint";
            host = "octopi.skynet.local";
            port = 80;
            path = "/";
            proto = "http";
            icon = "cube";
          }
          {
            name = "SkyNAS";
            host = "192.168.1.20";
            port = 5000;
            path = "/";
            proto = "http";
            icon = "hdd";
          }
          {
            name = "UniFi";
            host = "192.168.1.20";
            port = 8443;
            path = "/";
            proto = "https";
            icon = "network-wired";
          }
          {
            name = "Cable Modem";
            host = "192.168.100.1";
            port = 80;
            path = "/";
            proto = "http";
            icon = "satellite-dish";
          }
          {
            name = "Dell 2716 Switch";
            host = "192.168.1.2";
            port = 80;
            path = "/";
            proto = "http";
            icon = "ethernet";
          }
        ];
      };
    };
}
