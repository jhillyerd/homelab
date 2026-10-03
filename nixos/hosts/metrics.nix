{
  config,
  catalog,
  self,
  util,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

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

  # Prometheus metrics store for Consul (and future) agent metrics.
  services.prometheus = {
    enable = true;

    # promtool fails the build on the agenix credentials_file path, which
    # only exists at runtime.
    checkConfig = false;

    # Match influxdb telegraf-hosts retention.
    retentionTime = "26w";
    globalConfig.scrape_interval = "15s";

    scrapeConfigs = [
      {
        job_name = "consul";
        metrics_path = "/v1/agent/metrics";
        params = {
          format = [ "prometheus" ];
        };

        # ACL token with read-only agent/node access (see consul/README.md).
        authorization = {
          type = "Bearer";
          credentials_file = config.age.secrets.consul-metrics-token.path;
        };

        static_configs = [
          {
            targets = map (ip: "${ip}:8500") catalog.consul.servers;
            labels.role = "server";
          }
          {
            targets = [ "${catalog.nodes.nc-virt-1.ip.priv}:8500" ];
            labels.role = "client";
          }
        ];
      }
    ];
  };

  roles.mosquitto = {
    enable = true;

    users = {
      admin = {
        passwordFile = config.age.secrets.mqtt-admin.path;
        acl = [
          "readwrite $SYS/#"
          "readwrite #"
        ];
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
    inherit (catalog.monitors) http_response ping x509_certs;
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

    consul-metrics-token.file = ../secrets/consul-metrics-token.age;
    consul-metrics-token.owner = "prometheus";
  };

  # Grafana (nomad) queries the Prometheus HTTP API.
  networking.firewall.allowedTCPPorts = [ 9090 ];

  networking.firewall.enable = true;

  roles.upsmon = {
    enable = true;
    wave = 2;
  };
}
