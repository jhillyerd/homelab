{ config, catalog, self, util, ... }: {
  imports = [ ../common.nix ../common/onprem.nix ];

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
        retention = "26w";
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
    inherit (catalog.monitors) http_response ping;
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
