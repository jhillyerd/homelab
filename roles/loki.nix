{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.loki;
in
{
  options.roles.loki = {
    enable = mkEnableOption "Network Loki host";

    loki_http_port = mkOption {
      type = types.port;
      description = "Loki HTTP listen port";
      default = 3100;
    };

    promtail_http_port = mkOption {
      type = types.port;
      description = "Promtail HTTP listen port";
      default = 9080;
    };

    promtail_syslog_port = mkOption {
      type = types.port;
      description = "Promtail syslog listen port";
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

        schema_config.configs = [
          {
            from = "2021-01-01";
            store = "boltdb";
            object_store = "filesystem";
            schema = "v11";
            index.prefix = "index_";
          }
        ];

        storage_config = {
          boltdb.directory = "index";
          filesystem.directory = "chunks";
        };
      };
    };

    services.promtail = {
      enable = true;

      configuration = {
          server = {
            http_listen_port = cfg.promtail_http_port;
            grpc_listen_port = 0;
          };

          clients = [
            { url = "http://localhost:${toString cfg.loki_http_port}/loki/api/v1/push"; }
          ];

          scrape_configs = [
            {
              job_name = "syslog";
              syslog = {
                listen_address = "0.0.0.0:${toString cfg.promtail_syslog_port}";
                idle_timeout = "60s";
                label_structured_data = true;
                labels = {
                  job = "syslog";
                };
              };
              relabel_configs = [
                {
                  source_labels = [ "__syslog_message_hostname" ];
                  target_label = "host";
                }
                {
                  source_labels = [ "__syslog_message_app_name" ];
                  target_label = "app_name";
                }
              ];
            }
          ];
        };
    };

    networking.firewall.allowedTCPPorts = [ cfg.loki_http_port cfg.promtail_http_port cfg.promtail_syslog_port ];
  };
}
