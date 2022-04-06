{ config, pkgs, lib, nodes, environment, ... }:
let
  # Import low security credentials.
  lowsec = import ../lowsec.nix;

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
in {
  imports = [ ../common.nix ];

  roles.nfs-bind = {
    nfsPath = "192.168.1.20:/volume1/nexus_${environment}";

    binds = {
      "grafana" = {
        path = "/var/lib/grafana";
        user = "grafana";
        group = "grafana";
        mode = "0700";
      };

      "nodered" = {
        user = "1000";
        group = "1000";
        mode = "0700";
      };
    };

    before = [ "grafana.service" ];
  };

  roles.grafana = {
    enable = true;
    domain = "nexus.skynet.local";
    datasources =
      (lib.mapAttrsToList mkGrafanaInfluxSource config.roles.influxdb.databases)
      ++ [{
        name = "syslogs loki";
        type = "loki";
        access = "proxy";
        url = "http://localhost:${toString config.roles.loki.loki_http_port}";
        jsonData.maxLines = 1000;
      }];
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

  roles.loki = { enable = true; };

  roles.mosquitto = {
    enable = true;

    users = {
      admin = {
        password = lowsec.mqtt.admin.password;
        acl = [ "readwrite $SYS/#" "readwrite #" ];
      };
      sensor = {
        password = lowsec.mqtt.sensor.password;
        acl = [ ];
      };
    };
  };

  roles.homesite = {
    enable = true;

    # Service icons come from fontawesome-free.
    services = [
      {
        name = "Home Assistant";
        host = "homeassistant.bytemonkey.org";
        icon = "home";
      }
      {
        name = "Grafana";
        host = "grafana.bytemonkey.org";
        icon = "chart-area";
      }
      {
        name = "Node-RED";
        host = "nodered.bytemonkey.org";
        icon = "project-diagram";
      }
      {
        name = "OctoPrint";
        host = "octopi.bytemonkey.org";
        icon = "cube";
      }
      {
        name = "SkyNAS";
        host = "skynas.bytemonkey.org";
        icon = "hdd";
      }
      {
        name = "UniFi";
        host = "unifi.bytemonkey.org";
        icon = "network-wired";
      }
      {
        name = "Docker Registry";
        host = "dockreg.bytemonkey.org/v2/_catalog";
        icon = "brands fa-docker";
      }
      {
        name = "Cable Modem";
        host = "192.168.100.1";
        path = "/";
        proto = "http";
        icon = "satellite-dish";
      }
    ];
  };

  roles.traefik = {
    enable = true;
    certificateEmail = "james@hillyerd.com";
    cloudflareDnsApiToken = lowsec.cloudflare.dnsApi.token;

    services = {
      dockreg = {
        domainName = "dockreg.bytemonkey.org";
        backendUrls = [ "http://192.168.1.20:5050" ];
      };

      grafana = {
        domainName = "grafana.bytemonkey.org";
        backendUrls = [ "http://127.0.0.1:3000" ];
      };

      home = {
        domainName = "bytemonkey.org";
        backendUrls = [ "http://127.0.0.1:12701" ];
      };

      homeassistant = {
        domainName = "homeassistant.bytemonkey.org";
        backendUrls = [ "http://192.168.1.30:8123" ];
      };

      nodered = {
        domainName = "nodered.bytemonkey.org";
        backendUrls = [ "http://127.0.0.1:1880" ];
      };

      octopi = {
        domainName = "octopi.bytemonkey.org";
        backendUrls = [ "http://192.168.1.21" ];
      };

      skynas = {
        domainName = "skynas.bytemonkey.org";
        backendUrls = [ "https://192.168.1.20:5001" ];
      };

      unifi = {
        domainName = "unifi.bytemonkey.org";
        backendUrls = [ "https://192.168.1.20:8443" ];
      };
    };
  };

  roles.log-forwarder = {
    # Forward remote syslogs as well.
    enableTcpListener = true;
  };

  virtualisation.oci-containers.containers = {
    nodered = {
      image = "nodered/node-red:2.2.2";
      ports = [ "1880:1880" ];
      volumes = [ "/data/nodered:/data" ];
      environment = {
        NODE_RED_CREDENTIAL_SECRET = lowsec.nodered.credentialSecret;
      };
    };
  };
}
