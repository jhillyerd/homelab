{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) port;
  cfg = config.roles.loki;
in
{
  options.roles.loki = {
    enable = mkEnableOption "Network Loki host";

    loki_http_port = mkOption {
      type = port;
      description = "Loki HTTP listen port";
      default = 3100;
    };

    syslog_ingest_port = mkOption {
      type = port;
      description = "Syslog listen port";
      default = 1514;
    };
  };

  config = mkIf cfg.enable {
    services.loki = {
      enable = true;

      configuration = {
        auth_enabled = false;

        server = {
          http_listen_port = cfg.loki_http_port;
        };

        ingester = {
          lifecycler = {
            address = "localhost";
            ring = {
              kvstore.store = "inmemory";
              replication_factor = 1;
            };
            final_sleep = "0s";
          };

          chunk_idle_period = "5m";
          chunk_retain_period = "30s";
        };

        compactor = {
          working_directory = "retention";
          compaction_interval = "30m";
          retention_enabled = true;
          retention_delete_delay = "2h";
          retention_delete_worker_count = 30;
          delete_request_store = "filesystem";
        };

        limits_config.retention_period = "2160h"; # 90d

        schema_config.configs = [
          {
            from = "2024-05-02";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];

        storage_config = {
          filesystem.directory = "chunks";
          tsdb_shipper = {
            active_index_directory = "tsdb_active_index";
            cache_location = "tsdb_cache";
          };
        };
      };
    };

    # Listens on syslog_port and forwards logs to loki.
    services.alloy.enable = true;
    environment.etc."alloy/config.alloy".text = ''
      discovery.relabel "syslog" {
        targets = []

        rule {
          source_labels = ["__syslog_message_hostname"]
          target_label  = "host"
        }

        rule {
          source_labels = ["__syslog_message_app_name"]
          target_label  = "app_name"
        }
      }

      loki.source.syslog "syslog" {
        listener {
          address               = "0.0.0.0:${toString cfg.syslog_ingest_port}"
          protocol              = "tcp"
          idle_timeout          = "1m0s"
          label_structured_data = true
          max_message_length    = 0

          labels = {
            job = "syslog",
          }
        }

        forward_to    = [loki.write.default.receiver]
        relabel_rules = discovery.relabel.syslog.rules
      }

      loki.write "default" {
        endpoint {
          url = "http://localhost:${toString cfg.loki_http_port}/loki/api/v1/push"
        }
        external_labels = {}
      }
    '';

    # systemd.services.promtail = {
    #   # Forces promtail to be stopped before loki, preventing retry hang.
    #   after = [ "loki.service" ];
    # };

    networking.firewall.allowedTCPPorts = [
      cfg.loki_http_port
      cfg.syslog_ingest_port
    ];
  };
}
