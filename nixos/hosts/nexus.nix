{ config, pkgs, lib, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.dns.enable = true;
  roles.dns.serveLocalZones = true;

  roles.nfs-bind = {
    nfsPath = "192.168.1.20:/volume1/nexus_${environment}";

    binds = {
      "authelia" = {
        user = "0";
        group = "0";
        mode = "0770";
      };
    };

    before = [ "podman-authelia.service" ];
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

  # Configures traefik and homesite roles from service catalog.
  roles.websvc = {
    enable = true;

    internalDomain = "bytemonkey.org";
    externalDomain = "x.bytemonkey.org";

    cloudflareDnsApiTokenFile = config.age.secrets.cloudflare-dns-api.path;

    services = catalog.services;
    layout = catalog.layout;
  };

  virtualisation.oci-containers.containers = {
    authelia = {
      image = "authelia/authelia:4";
      ports = [ "9091:9091" ];
      volumes = [ "/data/authelia:/config" ];
    };
  };

  services.cfdyndns = {
    enable = true;
    email = catalog.cf-api.user;
    records = [ "home.bytemonkey.org" ];
  };

  systemd.services.cfdyndns = {
    startAt = lib.mkForce "*:07:00";
    script = lib.mkForce ''
      export CLOUDFLARE_APITOKEN="$(cat $CREDENTIALS_DIRECTORY/api.key)"
      ${pkgs.cfdyndns}/bin/cfdyndns
    '';

    serviceConfig.LoadCredential =
      "api.key:${config.age.secrets.cloudflare-dns-api.path}";
  };

  age.secrets = {
    cloudflare-dns-api.file = ../secrets/cloudflare-dns-api.age;

    influxdb-admin.file = ../secrets/influxdb-admin.age;
    influxdb-homeassistant.file = ../secrets/influxdb-homeassistant.age;

    mqtt-admin.file = ../secrets/mqtt-admin.age;
    mqtt-admin.owner = "mosquitto";

    mqtt-sensor.file = ../secrets/mqtt-sensor.age;
    mqtt-sensor.owner = "mosquitto";
  };
}
