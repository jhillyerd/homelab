{ config, pkgs, lib, catalog, ... }:
with lib;
let
  cfg = config.roles.nomad;
  datacenter = "skynet";
in
{
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

    hostVolumes = mkOption {
      type = attrsOf (submodule {
        options = {
          path = mkOption {
            type = path;
            description = "Path on host filesystem";
          };

          readOnly = mkOption {
            type = bool;
            description = "Prevents writes to volume";
            default = true;
          };
        };
      });
      description = "Host volumes";
      default = { };
    };
  };

  config = mkMerge [
    # Configure if either client or server is enabled.
    (mkIf (cfg.enableServer || cfg.enableClient) {
      age.secrets = {
        consul-encrypt.file = ../secrets/consul-encrypt.age;
        nomad-encrypt.file = ../secrets/nomad-encrypt.age;
      };

      # Create envfiles containing encryption keys when available.
      roles.envfile.files = {
        "consul-encrypt.hcl" = {
          secretPath = config.age.secrets.consul-encrypt.path;
          varName = "encrypt";
          quoteValue = true;
          owner = "consul";
        };

        "nomad-encrypt.hcl" = {
          secretPath = config.age.secrets.nomad-encrypt.path;
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
        extraConfigFiles =
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
        extraSettingsPaths =
          [ config.roles.envfile.files."nomad-encrypt.hcl".file ];
      };
    })

    # Nomad client config.
    (mkIf cfg.enableClient {
      services.nomad = {
        enableDocker = true;
        settings.client.enabled = true;
        settings.client.alloc_dir = mkIf (cfg.allocDir != null) cfg.allocDir;
        settings.client.host_volume = mkIf (cfg.hostVolumes != { }) cfg.hostVolumes;
      };

      systemd.services.nomad = {
        after = [ "remote-fs.target" ];
      };
    })
  ];
}
