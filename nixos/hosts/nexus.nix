{ config, pkgs, lib, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.dns.bind.enable = true;
  roles.dns.bind.serveLocalZones = true;

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

  roles.consul = {
    enableServer = true;
    retryJoin = catalog.consul.servers;
  };

  roles.nomad = {
    enableServer = true;
    retryJoin = catalog.nomad.servers;
  };

  roles.gateway-online.addr = "192.168.1.1";

  roles.tailscale.exitNode = true;

  age.secrets = {
    mqtt-admin.file = ../secrets/mqtt-admin.age;
    mqtt-admin.owner = "mosquitto";

    mqtt-clock.file = ../secrets/mqtt-clock.age;
    mqtt-clock.owner = "mosquitto";

    mqtt-sensor.file = ../secrets/mqtt-sensor.age;
    mqtt-sensor.owner = "mosquitto";

    mqtt-zwave.file = ../secrets/mqtt-zwave.age;
    mqtt-zwave.owner = "mosquitto";
  };

  networking.firewall.enable = false;
}
