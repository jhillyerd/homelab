{ config, pkgs, lib, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.dns.enable = true;
  roles.dns.serveLocalZones = true;

  roles.nfs-bind = {
    nfsPath = "192.168.1.20:/volume1/nexus_${environment}";

    binds = {
      "nodered" = {
        user = "1000";
        group = "1000";
        mode = "0700";
      };
    };
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

    retryJoin = with catalog.nodes; [ nexus.ip.priv nc-um350-1.ip.priv nc-um350-2.ip.priv ];
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
        name = "Gitea";
        host = "gitea.bytemonkey.org";
        icon = "code-branch";
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
        host = catalog.nodes.nexus.ip.priv;
        proto = "http";
        port = 8500;
        icon = "address-book";
      }
      {
        name = "Nomad";
        host = catalog.nodes.nexus.ip.priv;
        proto = "https";
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

  roles.gateway-online.addr = "192.168.1.1";

  virtualisation.oci-containers.containers = {
    nodered = {
      image = "nodered/node-red:2.2.2";
      ports = [ "1880:1880" ];
      volumes = [ "/data/nodered:/data" ];
      environmentFiles =
        [ config.roles.template.files."nodered-container.env".path ];
    };
  };

  # Create an environment file containing the nodered secret.
  roles.template.files."nodered-container.env" = {
    vars.secret = config.age.secrets.nodered.path;
    content = "NODE_RED_CREDENTIAL_SECRET=$secret";
  };

  age.secrets = {
    cloudflare-dns-api.file = ../secrets/cloudflare-dns-api.age;

    influxdb-admin.file = ../secrets/influxdb-admin.age;
    influxdb-homeassistant.file = ../secrets/influxdb-homeassistant.age;

    mqtt-admin.file = ../secrets/mqtt-admin.age;
    mqtt-admin.owner = "mosquitto";

    mqtt-sensor.file = ../secrets/mqtt-sensor.age;
    mqtt-sensor.owner = "mosquitto";

    nodered.file = ../secrets/nodered.age;
  };
}
