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

    nomadEncryptPath = mkOption {
      type = nullOr path;
      description = "Path to encryption key for nomad";
      default = null;
    };

    allocDir = mkOption {
      type = nullOr str;
      description = "Where nomad client stores alloc data";
      default = null;
    };

    dataDir = mkOption {
      type = str;
      description = "Where nomad stores its state";
      default = "/var/lib/nomad";
    };
  };

  config = mkMerge [
    # Configure if either client or server is enabled.
    (mkIf (cfg.enableServer || cfg.enableClient) {
      # Create envfiles containing encryption keys when available.
      roles.envfile.files = {
        "consul-encrypt.hcl" = mkIf (cfg.consulEncryptPath != null) {
          secretPath = cfg.consulEncryptPath;
          varName = "encrypt";
          quoteValue = true;
          owner = "consul";
        };

        "nomad-encrypt.hcl" = mkIf (cfg.nomadEncryptPath != null) {
          secretPath = cfg.nomadEncryptPath;
          content = ''
            server {
              encrypt = "$SECRET"
            }
          '';
          mode = "0444";
        };
      };

      services.consul = {
        enable = true;

        interface.bind = cfg.consulBind;

        extraConfig = {
          retry_join = cfg.retryJoin;
          retry_interval = "15s";
          inherit datacenter;
        };

        # Install extra HCL file to hold encryption key.
        extraConfigFiles = mkIf (cfg.consulEncryptPath != null)
          [ config.roles.envfile.files."consul-encrypt.hcl".file ];
      };

      services.nomad = {
        enable = true;
        dropPrivileges = false;

        settings = {
          datacenter = datacenter;
          data_dir = cfg.dataDir;
          bind_addr = ''{{ GetInterfaceIP "${catalog.tailscale.interface}" }}'';
        };
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

      services.nomad = {
        settings.server = {
          enabled = true;
          bootstrap_expect = 3;
        };

        # Install extra HCL file to hold encryption key.
        extraSettingsPaths = mkIf (cfg.nomadEncryptPath != null)
          [ config.roles.envfile.files."nomad-encrypt.hcl".file ];
      };
    })

    # Nomad client config.
    (mkIf cfg.enableClient {
      services.nomad = {
        enableDocker = true;
        settings.client.enabled = true;
        settings.client.alloc_dir = mkIf (cfg.allocDir != null) cfg.allocDir;
      };
    })
  ];
}
