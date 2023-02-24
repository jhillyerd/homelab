{ config, pkgs, lib, catalog, self, ... }:
with lib;
let
  cfg = config.roles.consul;
  datacenter = "skynet";
in
{
  options.roles.consul = with types; {
    enableServer = mkEnableOption "Enable Consul Server";

    retryJoin = mkOption {
      type = listOf str;
      description = "List of server host or IPs to join to datacenter";
    };

    client = mkOption {
      type = submodule {
        options = {
          enable = mkEnableOption "Enable Consul Client";
          connect = mkEnableOption "Enable Consul Connect mesh";
        };
      };
      default = { };
    };
  };

  config = mkMerge [
    # Configure if either client or server is enabled.
    (mkIf (cfg.enableServer || cfg.client.enable) {
      # Consul shared client & server config.
      services.consul = {
        enable = true;

        extraConfig = {
          inherit datacenter;

          bind_addr = self.ip.priv;
          client_addr = "0.0.0.0";

          retry_join = filter (x: x != self.ip.priv) cfg.retryJoin;
          retry_interval = "15s";

          tls = {
            internal_rpc.verify_server_hostname = true;

            # Encrypt and verify outgoing TLS.
            defaults = {
              ca_file = ./files/consul/consul-agent-ca.pem;
              verify_incoming = mkDefault false;
              verify_outgoing = true;
            };
          };

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

      age.secrets = {
        consul-encrypt.file = ../secrets/consul-encrypt.age;
      };

      # Create envfiles containing encryption keys.
      roles.template.files = {
        "consul-encrypt.hcl" = {
          vars.encrypt = config.age.secrets.consul-encrypt.path;
          content = ''encrypt = "$encrypt"'';
          owner = "consul";
        };
      };

      systemd.services.consul = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };

      networking.firewall.allowedTCPPorts = [ 8300 8301 8302 8500 8501 8502 8503 8600 ];
      networking.firewall.allowedUDPPorts = [ 8301 8302 8600 ];
    })

    (mkIf (cfg.client.enable && cfg.client.connect) {
      # Consul service mesh config.
      services.consul = {
        extraConfig = {
          connect.enabled = true;
          ports.grpc = 8502;
          ports.grpc_tls = 8503;
        };
      };
    })

    (mkIf cfg.enableServer {
      # Consul server config.
      services.consul = {
        webUi = true;

        extraConfig = {
          server = true;

          bootstrap_expect = 3;

          # Encrypt and verify TLS.
          tls.defaults = {
            cert_file = ./files/consul/skynet-server-consul-0.pem;
            key_file = config.age.secrets."skynet-server-consul-0-key.pem".path;

            verify_incoming = true;
          };

          # Create certs for clients.
          connect.enabled = true;
          auto_encrypt.allow_tls = true;
        };
      };

      age.secrets = {
        "skynet-server-consul-0-key.pem" = {
          file = ../secrets/skynet-server-consul-0-key.pem.age;
          owner = "consul";
        };
      };
    })

    (mkIf (cfg.client.enable && !cfg.enableServer) {
      # Consul client only config.
      services.consul = {
        extraConfig = {
          # Get our certificate from the server.
          auto_encrypt.tls = true;
        };

        # Install extra HCL file to hold encryption key.
        extraConfigFiles =
          [ config.roles.template.files."consul-agent-token.hcl".path ];
      };

      # Template config file for agent token.
      roles.template.files = {
        "consul-agent-token.hcl" = {
          vars.token = config.age.secrets.consul-agent-token.path;
          content = ''acl { tokens { default = "$token" } }'';
          owner = "consul";
        };
      };

      age.secrets = {
        "consul-agent-token" = {
          file = ../secrets/consul-agent-token.age;
          owner = "consul";
        };
      };
    })
  ];
}

