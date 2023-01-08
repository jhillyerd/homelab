{ config, pkgs, lib, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.dns.enable = true;
  roles.dns.serveLocalZones = true;

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

  roles.loki.enable = true;

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
    retryJoin = catalog.nomad.servers;
  };

  roles.log-forwarder = {
    # Forward remote syslogs as well.
    enableTcpListener = true;
  };

  roles.gateway-online.addr = "192.168.1.1";

  roles.tailscale.exitNode = true;

  roles.telegraf = {
    http_response = [
      {
        # TODO Give Consul a LB entry.
        urls = [ "http://nexus.bytemonkey.org:8500/ui/" ];
        response_status_code = 200;
      }
      {
        urls = [ "https://dockreg.bytemonkey.org/v2/" ];
        response_status_code = 200;
      }
      {
        urls = [ "https://gitea.bytemonkey.org" ];
        response_status_code = 200;
      }
      {
        urls = [ "https://grafana.bytemonkey.org/" ];
        response_status_code = 401;
      }
      {
        urls = [ "http://homeassistant.home.arpa:8123" ];
        response_status_code = 200;
      }
      {
        urls = [ "https://inbucket.bytemonkey.org/" ];
        response_status_code = 200;
      }
      {
        urls = [ "https://nodered.bytemonkey.org" ];
        response_status_code = 200;
      }
      {
        urls = [ "https://nomad.bytemonkey.org/ui/" ];
        response_status_code = 200;
      }
      {
        urls = [ "http://octopi.home.arpa" ];
        response_status_code = 302;
      }
    ];

    ping = [
      "gateway.home.arpa"
      "homeassistant.home.arpa"
      "nexus.home.arpa"
      "nc-um350-1.home.arpa"
      "nc-um350-2.home.arpa"
      "octopi.home.arpa"
      "skynas.home.arpa"
    ];
  };

  age.secrets = {
    influxdb-admin.file = ../secrets/influxdb-admin.age;
    influxdb-homeassistant.file = ../secrets/influxdb-homeassistant.age;

    mqtt-admin.file = ../secrets/mqtt-admin.age;
    mqtt-admin.owner = "mosquitto";

    mqtt-sensor.file = ../secrets/mqtt-sensor.age;
    mqtt-sensor.owner = "mosquitto";
  };
}
