{ config, pkgs, lib, catalog, ... }:
with lib;
let
  cfg = config.roles.nomad;
  datacenter = "skynet";
in {
  options.roles.nomad = with types; {
    enableServer = mkEnableOption "Enable Nomad Server (Coordinator)";
    enableClient = mkEnableOption "Enable Nomad Client (Worker)";

    retryJoin = mkOption {
      type = listOf str;
      description = "List of server host or IPs to join to datacenter";
    };

    consulBind = mkOption {
      type = nullOr str;
      description = "The name of the interface to pull consul bind addr from";
      default = null;
    };

    consulEncryptPath = mkOption {
      type = nullOr path;
      description = "Path to encryption key for consul";
      default = null;
    };
  };

  config = mkMerge [
    # Configure if either client or server is enabled.
    (mkIf (cfg.enableServer || cfg.enableClient) {
      roles.envfile.files."consul-encrypt.hcl" =
        mkIf (cfg.consulEncryptPath != null) {
          secretPath = cfg.consulEncryptPath;
          varName = "encrypt";
          quoteValue = true;
          owner = "consul";
        };

      services.consul = {
        enable = true;

        interface.bind = cfg.consulBind;

        extraConfig = {
          retry_join = cfg.retryJoin;
          retry_interval = "15s";
          inherit datacenter;
        };

        extraConfigFiles = mkIf (cfg.consulEncryptPath != null)
          [ config.roles.envfile.files."consul-encrypt.hcl".file ];
      };

      services.nomad = {
        enable = true;
        settings.datacenter = datacenter;
        settings.bind_addr =
          ''{{ GetInterfaceIP "${catalog.tailscale.interface}" }}'';
      };
    })

    # Nomad server config.
    (mkIf cfg.enableServer {
      services.consul = {
        webUi = true;

        extraConfig = {
          server = true;
          bootstrap_expect = 3;
          client_addr = "0.0.0.0";
        };
      };

      services.nomad.settings.server = {
        enabled = true;
        bootstrap_expect = 3;
      };
    })

    # Nomad client config.
    (mkIf cfg.enableClient {
      services.nomad = {
        enableDocker = true;
        settings.client.enabled = true;
      };
    })
  ];
}
