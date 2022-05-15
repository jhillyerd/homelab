{ config, pkgs, lib, environment, catalog, ... }: {
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

  roles.grafana =
    let
      # Construct a grafana datasource from our influxdb database definition.
      mkGrafanaInfluxSource = name: db: {
        name = "${name} influxdb";
        type = "influxdb";
        database = name;
        # TODO don't use localhost.
        url = "http://localhost:${toString config.roles.influxdb.port}";
        user = db.user;
        secureJsonData.password = "$__file{${db.passwordFile}}";
      };
    in
    {
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
    adminUser = "admin";
    adminPasswordFile = config.age.secrets.influxdb-admin.path;

    databases = {
      homeassistant = {
        user = "homeassistant";
        passwordFile = config.age.secrets.influxdb-homeassistant.path;
      };

      telegraf-hosts = {
        user = "telegraf";
        passwordFile = config.age.secrets.influxdb-telegraf.path;
      };
    };
  };

  roles.loki = { enable = true; };

  roles.mosquitto = {
    enable = true;

    users = {
      admin = {
        passwordFile = config.age.secrets.mqtt-admin.path;
        acl = [ "readwrite $SYS/#" "readwrite #" ];
      };
      sensor = {
        passwordFile = config.age.secrets.mqtt-sensor.path;
        acl = [ ];
      };
    };
  };

  roles.nomad = {
    enableServer = true;

    retryJoin = with catalog.nodes; [ nexus.ip nc-um350-1.ip nc-um350-2.ip ];
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
        name = "Inbucket";
        host = "nomad.bytemonkey.org/inbucket";
        icon = "at";
      }
      {
        name = "UniFi";
        host = "unifi.bytemonkey.org";
        icon = "network-wired";
      }
      {
        name = "Consul";
        host = catalog.nodes.nexus.ip;
        proto = "http";
        port = 8500;
        icon = "address-book";
      }
      {
        name = "Nomad";
        host = catalog.nodes.nexus.ip;
        proto = "http";
        port = 4646;
        icon = "server";
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
    cloudflareDnsApiTokenFile = config.age.secrets.cloudflare-dns-api.path;

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
      environmentFiles =
        [ config.roles.envfile.files."nodered-container.env".file ];
    };
  };

  # Create an environment file containing the nodered secret.
  roles.envfile = {
    files."nodered-container.env" = {
      secretPath = config.age.secrets.nodered.path;
      varName = "NODE_RED_CREDENTIAL_SECRET";
      quoteValue = false;
    };
  };

  age.secrets = {
    cloudflare-dns-api.file = ../secrets/cloudflare-dns-api.age;

    influxdb-admin.file = ../secrets/influxdb-admin.age;
    influxdb-homeassistant.file = ../secrets/influxdb-homeassistant.age;
    influxdb-homeassistant.owner = "grafana";

    # Secret file defined in common.nix.
    influxdb-telegraf.owner = "grafana";

    mqtt-admin.file = ../secrets/mqtt-admin.age;
    mqtt-admin.owner = "mosquitto";

    mqtt-sensor.file = ../secrets/mqtt-sensor.age;
    mqtt-sensor.owner = "mosquitto";

    nodered.file = ../secrets/nodered.age;
  };
}
