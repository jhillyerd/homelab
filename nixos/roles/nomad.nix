{ config, pkgs, lib, ... }:
with lib;
let
  nserver = config.roles.nomad-server;
  nclient = config.roles.nomad-client;
in {
  options.roles.nomad-server = with types; {
    enable = mkEnableOption "Enable Nomad Server (Coordinator)";

    retryJoin = mkOption {
      type = listOf str;
      description = "List of server host or IPs to join to datacenter";
    };
  };

  options.roles.nomad-client = {
    enable = mkEnableOption "Enable Nomad Client (Worker)";
  };

  config = mkMerge [
    # Configure if either client or server is enabled.
    (mkIf (nserver.enable || nclient.enable) {
      services.nomad = {
        enable = true;

        settings.datacenter = "skynet";
      };
    })

    # Nomad server config.
    (mkIf nserver.enable {
      services.nomad.settings.server = {
        enabled = true;
        bootstrap_expect = 3;

        server_join = {
          retry_join = nserver.retryJoin;
          retry_interval = "15s";
          retry_max = 40;
        };
      };
    })

    # Nomad client config.
    (mkIf nclient.enable {
      services.nomad = {
        enableDocker = true;

        settings.client.enabled = true;
      };
    })
  ];
}
