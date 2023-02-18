{ config, pkgs, lib, catalog, ... }:
with lib;
let
  cfg = config.roles.consul;
  datacenter = "skynet";
in
{
  options.roles.consul = with types; {
    enableServer = mkEnableOption "Enable Consul Server";
    enableClient = mkEnableOption "Enable Consul Client";

    retryJoin = mkOption {
      type = listOf str;
      description = "List of server host or IPs to join to datacenter";
    };
  };

  config = mkMerge [
    # Configure if either client or server is enabled.
    (mkIf (cfg.enableServer || cfg.enableClient) {
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

          ca_file = ./files/consul/consul-agent-ca.pem;

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
          auto_encrypt.allow_tls = true;
          verify_incoming = mkForce true;

          cert_file = ./files/consul/skynet-server-consul-0.pem;
          key_file = config.age.secrets."skynet-server-consul-0-key.pem".path;
        };
      };

      networking.firewall.allowedTCPPorts = [ 8300 8301 8302 8500 8501 8502 8600 ];
      networking.firewall.allowedUDPPorts = [ 8301 8302 8600 ];
    })

    (mkIf cfg.enableClient { })
  ];
}
