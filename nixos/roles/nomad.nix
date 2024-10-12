{ config, pkgs, lib, ... }:
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

    client = mkOption {
      type = submodule {
        options = {
          meta = mkOption {
            type = attrs;
            description = "Nomad metadata entries";
            default = { };
          };
        };
      };
      description = "Client (worker) Nomad configuration";
      default = { };
    };

    usb = mkOption {
      type = submodule {
        options = {
          enable = mkEnableOption "Enable Nomad USB plugin";

          includedVendorIds = mkOption {
            type = listOf ints.unsigned;
            default = [ ];
          };

          includedProductIds = mkOption {
            type = listOf ints.unsigned;
            default = [ ];
          };
        };
      };
      description = "USB plugin configuration";
      default = { };
    };
  };

  config = mkMerge [
    # Configure if either client or server is enabled.
    (mkIf (cfg.enableServer || cfg.enableClient) {
      age.secrets = {
        nomad-consul-token.file = ../secrets/nomad-consul-token.age;
        nomad-encrypt.file = ../secrets/nomad-encrypt.age;
        nomad-server-client-key.file = ../secrets/nomad-server-client-key.age;
      };

      # Create envfiles containing encryption keys.
      age-template.files = {
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

      systemd.services.nomad = {
        after = [ "consul.service" ];
        wants = [ "consul.service" ];
      };

      # Nomad shared client & server config.
      services.nomad = {
        enable = true;
        package = pkgs.nomad_1_7;

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

            # Allow CLI, loadbalancers, browsers without client certs.
            verify_https_client = false;
          };

        };

        extraPackages =
          let
            arch = {
              any = [ pkgs.cni-plugins pkgs.consul ];
              x86_64-linux = [ pkgs.qemu_kvm pkgs.getent ];
              aarch64-linux = [ ];
            };
          in
          lib.lists.flatten [ arch.${pkgs.system} arch.any ];

        # Install extra HCL file to hold secrets.
        extraSettingsPaths =
          [ config.age-template.files."nomad-secrets.hcl".path ];
      };

      networking.firewall.allowedTCPPorts = [ 4646 4647 ];
    })

    (mkIf cfg.enableServer {
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
        };
      };

      networking.firewall.allowedTCPPorts = [ 4648 ];
      networking.firewall.allowedUDPPorts = [ 4648 ];
    })

    (mkIf cfg.enableClient {
      # Nomad client config.
      services.nomad = {
        enableDocker = true;

        settings = {
          client = {
            enabled = true;
            alloc_dir = mkIf (cfg.allocDir != null) cfg.allocDir;
            cni_path = "${pkgs.cni-plugins}/bin";

            host_volume = mkIf (cfg.hostVolumes != { }) (mapAttrs
              (name: entry: {
                inherit (entry) path;
                read_only = entry.readOnly;
              })
              cfg.hostVolumes);

            meta = cfg.client.meta;
          };

          telemetry = {
            publish_allocation_metrics = true;
            publish_node_metrics = true;
            prometheus_metrics = true;
          };

          # Nomad client requires client cert if not also a server.
          tls.verify_https_client = mkDefault true;

          plugin.docker = {
            config = {
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

              gc = {
                image_delay = "60m";
              };
            };

          };

          plugin.usb.config = mkIf cfg.usb.enable {
            enabled = true;
            included_vendor_ids = cfg.usb.includedVendorIds;
            included_product_ids = cfg.usb.includedProductIds;
          };
        };

        extraSettingsPlugins = mkIf cfg.usb.enable [ pkgs.nomad-usb-device-plugin ];
      };

      systemd.services.nomad = {
        after = [ "remote-fs.target" ];
      };
    })
  ];
}
