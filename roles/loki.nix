{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.loki;
in
{
  options.roles.loki = {
    enable = mkEnableOption "Network Loki host";

    port = mkOption {
      type = types.port;
      description = "Listen port";
      default = 3100;
    };
  };

  config = mkIf cfg.enable {
    services.loki = {
      enable = true;

      configuration = {
        auth_enabled = false;

        server = {
          http_listen_port = cfg.port;
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

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
