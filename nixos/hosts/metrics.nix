{
  config,
  catalog,
  lib,
  self,
  util,
  ...
}:
let
  # Probe origins for the nfs-path blackbox jobs (see
  # nfs-path-monitoring-plan): dns_sd only knows IPs, so relabel a
  # node=<hostname> label to match the node_* and consul_* series.
  probeNodes = [
    "nc-virt-1"
    "nc-um350-1"
    "nc-um350-2"
  ];
  nodeRelabel = map (name: {
    source_labels = [ "__address__" ];
    regex = "(${lib.strings.escapeRegex catalog.nodes.${name}.ip.priv}):.*";
    target_label = "node";
    replacement = name;
  }) probeNodes;
in
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
      {
        # Per-check health metrics (see nomad/consul-exporter.nomad).
        job_name = "consul-exporter";
        static_configs = [
          { targets = [ "consul-exporter.service.consul:9107" ]; }
        ];
      }
      {
        # Nomad agent telemetry (jobs, allocs, autopilot). /v1/metrics is
        # ACL-exempt so needs no token, but the TLS certs are issued for
        # nomad.service.consul rather than target IPs, so skip verification.
        # Leader-only gauges arrive double-prefixed, e.g.
        # nomad_nomad_job_summary_* — see the monitoring plan.
        job_name = "nomad";
        scheme = "https";
        metrics_path = "/v1/metrics";
        params = {
          format = [ "prometheus" ];
        };
        tls_config.insecure_skip_verify = true;

        static_configs = [
          {
            targets = map (ip: "${ip}:4646") catalog.nomad.servers;
            labels = {
              role = "server";
              # Nomad metrics carry no cluster label (datacenter is only on
              # nomad_client_uptime); mrkaran dashboards 16923-5 filter on it.
              cluster = "skynet";
            };
          }
          {
            targets = [ "${catalog.nodes.nc-virt-1.ip.priv}:4646" ];
            labels = {
              role = "client";
              cluster = "skynet";
            };
          }
        ];
      }
      {
        # NFS path monitoring (see nfs-path-monitoring-plan): blackbox
        # ICMP probes from every nomad client's exporter to the NAS and
        # the gateway. Targets are found via consul DNS so new clients
        # are covered automatically; instance stays the probe origin.
        job_name = "blackbox-icmp-nas";
        metrics_path = "/probe";
        params = {
          module = [ "icmp" ];
          target = [ "192.168.1.10" ]; # mininas
        };
        dns_sd_configs = [
          {
            names = [ "blackbox-exporter.service.consul" ];
            type = "A";
            port = 9115;
          }
        ];
        relabel_configs = nodeRelabel ++ [
          {
            source_labels = [ "__address__" ];
            target_label = "instance";
          }
          {
            target_label = "probe_target";
            replacement = "mininas";
          }
        ];
      }
      {
        job_name = "blackbox-icmp-gateway";
        metrics_path = "/probe";
        params = {
          module = [ "icmp" ];
          target = [ "192.168.1.1" ]; # unifi gateway
        };
        dns_sd_configs = [
          {
            names = [ "blackbox-exporter.service.consul" ];
            type = "A";
            port = 9115;
          }
        ];
        relabel_configs = nodeRelabel ++ [
          {
            source_labels = [ "__address__" ];
            target_label = "instance";
          }
          {
            target_label = "probe_target";
            replacement = "gateway";
          }
        ];
      }
      {
        # Control for nfsd starvation: TCP connect to mininas:2049 from
        # each client. Failing here while ICMP is clean points at the
        # NFS daemon rather than the network path.
        job_name = "blackbox-tcp-nfsd";
        metrics_path = "/probe";
        params = {
          module = [ "tcp_connect" ];
          target = [ "192.168.1.10:2049" ];
        };
        dns_sd_configs = [
          {
            names = [ "blackbox-exporter.service.consul" ];
            type = "A";
            port = 9115;
          }
        ];
        relabel_configs = nodeRelabel ++ [
          {
            source_labels = [ "__address__" ];
            target_label = "instance";
          }
          {
            target_label = "probe_target";
            replacement = "mininas-nfsd";
          }
        ];
      }
      {
        # Nomad client host metrics (nfs-path-monitoring-plan phase 2):
        # mountstats collector exposes per-mount NFS RPC counters from
        # /proc/self/mountstats. Host module, not a nomad job, so it
        # survives a nomad outage.
        job_name = "node";
        static_configs = [
          {
            targets = [ "${catalog.nodes.nc-virt-1.ip.priv}:9100" ];
            labels.node = "nc-virt-1";
          }
          {
            targets = [ "${catalog.nodes.nc-um350-1.ip.priv}:9100" ];
            labels.node = "nc-um350-1";
          }
          {
            targets = [ "${catalog.nodes.nc-um350-2.ip.priv}:9100" ];
            labels.node = "nc-um350-2";
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
