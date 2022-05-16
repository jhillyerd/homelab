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

      systemd.services.consul = {
        after = [ "network-online.target" ];
      };

      systemd.services.nomad = {
        after = [ "network-online.target" ];
      };

      services.consul = {
        enable = true;

        extraConfig = {
          bind_addr = ''{{ GetDefaultInterfaces | exclude "type" "IPv6" | limit 1 | attr "address" }}'';
          retry_join = cfg.retryJoin;
          retry_interval = "15s";
          inherit datacenter;

          # Encrypt and verify TLS.
          verify_incoming = false;
          verify_outgoing = true;
          verify_server_hostname = true;
          auto_encrypt.allow_tls = true;

          ca_file = ./files/nomad/consul-agent-ca.pem;

          acl = {
            enabled = true;
            default_policy = "allow";
            enable_token_persistence = true;
          };
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
          bind_addr = ''{{ GetDefaultInterfaces | exclude "type" "IPv6" | limit 1 | attr "address" }}'';
        };
      };
    })

    # Nomad server config.
    (mkIf cfg.enableServer {
      age.secrets = {
        "skynet-server-consul-0-key.pem".file = ../secrets/skynet-server-consul-0-key.pem.age;
        "skynet-server-consul-0-key.pem".owner = "consul";
      };

      services.consul = {
        webUi = true;

        extraConfig = {
          server = true;
          bootstrap_expect = 3;
          client_addr = "0.0.0.0";

          # Encrypt and verify TLS.
          verify_incoming = mkForce true;

          cert_file = ./files/nomad/skynet-server-consul-0.pem;
          key_file = config.age.secrets."skynet-server-consul-0-key.pem".path;
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

      networking.firewall.allowedTCPPorts = [ 4646 4647 4648 8300 8301 8302 8500 8501 8502 8600 ];
      networking.firewall.allowedUDPPorts = [ 4648 8301 8302 8600 ];
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
