{ config, pkgs, lib, environment, catalog, self, util, ... }: {
  imports = [ ../common.nix ];

  fileSystems."/var" = {
    device = "/dev/disk/by-label/var";
    fsType = "ext4";
  };

  systemd.network.networks = util.mkClusterNetworks self;

  # Telegraf service status goes through tailnet.
  roles.tailscale.enable = true;

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
      clock = {
        passwordFile = config.age.secrets.mqtt-clock.path;
        acl = [ "readwrite clock/#" ];
      };
      sensor = {
        passwordFile = config.age.secrets.mqtt-sensor.path;
        acl = [ ];
      };
      zwave = {
        passwordFile = config.age.secrets.mqtt-zwave.path;
        acl = [ "readwrite zwave/#" ];
      };
    };
  };

  roles.log-forwarder = {
    # Forward remote syslogs as well.
    enableTcpListener = true;
  };

  roles.gateway-online.addr = "192.168.1.1";

  roles.telegraf = {
    http_response = [
      {
        # TODO Give Consul a LB entry.
        urls = [ "http://nexus.bytemonkey.org:8500/ui/" ];
        response_status_code = 200;
      }
      {
        urls = [ "http://demo.inbucket.org/status" ];
        response_status_code = 200;
      }
      {
        urls = [ "https://dockreg.home.arpa/v2/" ];
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
        urls = [ "https://homeassistant.bytemonkey.org/" ];
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
      {
        urls = [ "https://zwavejs.bytemonkey.org/" ];
        response_status_code = 200;
      }
    ];

    ping = [
      "gateway.home.arpa"
      "nexus.home.arpa"
      "nc-um350-1.home.arpa"
      "nc-um350-2.home.arpa"
      "octopi.home.arpa"
      "pve1.home.arpa"
      "pve2.home.arpa"
      "pve3.home.arpa"
      "skynas.home.arpa"
      "web.home.arpa"
    ];
  };

  age.secrets = {
    influxdb-admin.file = ../secrets/influxdb-admin.age;
    influxdb-homeassistant.file = ../secrets/influxdb-homeassistant.age;

    mqtt-admin.file = ../secrets/mqtt-admin.age;
    mqtt-admin.owner = "mosquitto";

    mqtt-clock.file = ../secrets/mqtt-clock.age;
    mqtt-clock.owner = "mosquitto";

    mqtt-sensor.file = ../secrets/mqtt-sensor.age;
    mqtt-sensor.owner = "mosquitto";

    mqtt-zwave.file = ../secrets/mqtt-zwave.age;
    mqtt-zwave.owner = "mosquitto";
  };

  networking.firewall.enable = true;
}
