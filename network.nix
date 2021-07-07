let
  # Import low security credentials.
  lowsec = import ./lowsec.nix;
in
{ environment ? "test" }:
{
  network.description = "Home Services";

  defaults =
    { pkgs, nodes, ... }:
    let
      influxHost = "nexus";
      influxPort = nodes.nexus.config.roles.influxdb.port;

      syslogHost = "nexus";
      syslogPort = nodes.nexus.config.roles.loki.promtail_syslog_port;
    in
    {
      imports = [ ./common.nix ./roles ./modules/promtail.nix ];

      nixpkgs.overlays = [ (import ./pkgs/overlay.nix) ];

      # Configure telegraf agent.
      roles.telegraf = {
        enable = true;
        influxdb = {
          urls = [ "http://${influxHost}:${toString influxPort}" ];
          database = "telegraf-hosts";
          username = lowsec.influxdb.telegraf.user;
          password = lowsec.influxdb.telegraf.password;
        };
      };

      # Forward syslogs to promtail/loki.
      roles.log-forwarder = {
        enable = true;
        inherit syslogHost syslogPort;
      };
    };

  nexus =
    { config, pkgs, lib, nodes, resources, ... }:
    let
      # Construct a grafana datasource from our influxdb database definition.
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
      roles.nfs-bind = {
        nfsPath = "192.168.1.20:/volume1/nexus_${environment}";

        binds."grafana" = {
          path = "/var/lib/grafana";
          user = "grafana";
          group = "grafana";
          mode = "0700";
        };

        before = [ "grafana.service" ];
      };

      roles.grafana = {
        enable = true;
        domain = "nexus.skynet.local";
        datasources = (lib.mapAttrsToList mkGrafanaInfluxSource config.roles.influxdb.databases) ++ [
          {
            name = "syslogs loki";
            type = "loki";
            access = "proxy";
            url = "http://localhost:${toString config.roles.loki.loki_http_port}";
            jsonData.maxLines = 1000;
          }
        ];
      };

      roles.influxdb = {
        enable = true;
        adminUser = lowsec.influxdb.admin.user;
        adminPassword = lowsec.influxdb.admin.password;

        databases = {
          homeassistant = {
            user = lowsec.influxdb.homeassistant.user;
            password = lowsec.influxdb.homeassistant.password;
          };

          telegraf-hosts = {
            user = lowsec.influxdb.telegraf.user;
            password = lowsec.influxdb.telegraf.password;
          };
        };
      };

      roles.loki = {
        enable = true;
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
            host = "nexus.skynet.local";
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
        ];
      };

      roles.log-forwarder = {
        # Forward remote syslogs as well.
        enableTcpListener = true;
      };
    };
}
