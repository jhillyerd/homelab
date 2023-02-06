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
        nomad-consul-token.file = ../secrets/nomad-consul-token.age;
        nomad-encrypt.file = ../secrets/nomad-encrypt.age;
        nomad-server-client-key.file = ../secrets/nomad-server-client-key.age;
      };

      # Create envfiles containing encryption keys.
      roles.template.files = {
        "consul-encrypt.hcl" = {
          vars.encrypt = config.age.secrets.consul-encrypt.path;
          content = ''encrypt = "$encrypt"'';
          owner = "consul";
        };

        "nomad-secrets.hcl" = {
          vars = {
            consulToken = config.age.secrets.nomad-consul-token.path;
            encrypt = config.age.secrets.nomad-encrypt.path;
          };
          content = ''
            consul {
              token = "$consulToken"
            }
            server {
              encrypt = "$encrypt"
            }
          '';
        };
      };

      systemd.services.consul = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };

      systemd.services.nomad = {
        after = [ "consul.service" ];
        wants = [ "consul.service" ];
      };

      # Consul shared client & server config.
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
            default_policy = "deny";
            enable_token_persistence = true;
          };
        };

        # Install extra HCL file to hold encryption key.
        extraConfigFiles =
          [ config.roles.template.files."consul-encrypt.hcl".path ];
      };

      # Nomad shared client & server config.
      services.nomad = {
        enable = true;
        package = pkgs.nomad_1_4;

        dropPrivileges = false;

        settings = {
          datacenter = datacenter;
          data_dir = cfg.dataDir;
          bind_addr = "0.0.0.0";

          acl.enabled = true;

          tls = {
            http = true;
            rpc = true;

            ca_file = "${./files/nomad/nomad-ca.pem}";
            cert_file = "${./files/nomad/server-client.pem}";
            key_file = config.age.secrets.nomad-server-client-key.path;

            verify_server_hostname = true;
          };
        };

        extraPackages = [ pkgs.cni-plugins pkgs.qemu_kvm pkgs.getent ];
      };
    })

    (mkIf cfg.enableServer {
      age.secrets = {
        "skynet-server-consul-0-key.pem".file = ../secrets/skynet-server-consul-0-key.pem.age;
        "skynet-server-consul-0-key.pem".owner = "consul";
      };

      # Consul server config.
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

      # Nomad server config.
      services.nomad = {
        settings = {
          server = {
            enabled = true;
            bootstrap_expect = 3;

            default_scheduler_config = {
              scheduler_algorithm = "spread";
              memory_oversubscription_enabled = true;
            };
          };

          # Allow CLI, loadbalancers, browsers without client certs.
          tls.verify_https_client = false;

        };

        # Install extra HCL file to hold secrets.
        extraSettingsPaths =
          [ config.roles.template.files."nomad-secrets.hcl".path ];
      };

      networking.firewall.allowedTCPPorts = [ 4646 4647 4648 8300 8301 8302 8500 8501 8502 8600 ];
      networking.firewall.allowedUDPPorts = [ 4648 8301 8302 8600 ];
    })

    (mkIf cfg.enableClient {
      # Nomad client config.
      services.nomad = {
        enableDocker = true;

        settings = {
          client.enabled = true;
          client.alloc_dir = mkIf (cfg.allocDir != null) cfg.allocDir;
          client.host_volume = mkIf (cfg.hostVolumes != { }) (mapAttrs
            (name: entry: {
              inherit (entry) path;
              read_only = entry.readOnly;
            })
            cfg.hostVolumes);

          telemetry = {
            publish_allocation_metrics = true;
            publish_node_metrics = true;
            prometheus_metrics = true;
          };

          # Nomad client requires client cert if not also a server.
          tls.verify_https_client = mkDefault true;

          plugin.docker.config = {
            # Defaults + net_raw; ping is useful in a home lab.
            allow_caps = [
              "audit_write"
              "chown"
              "dac_override"
              "fowner"
              "fsetid"
              "kill"
              "mknod"
              "net_bind_service"
              "net_raw"
              "setfcap"
              "setgid"
              "setpcap"
              "setuid"
              "sys_chroot"
            ];

            extra_labels = [
              "job_name"
              "task_group_name"
              "task_name"
              "namespace"
              "node_name"
            ];
          };
        };
      };

      systemd.services.nomad = {
        after = [ "remote-fs.target" ];
      };
    })
  ];
}
