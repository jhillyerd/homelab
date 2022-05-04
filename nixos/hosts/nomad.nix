{ config, pkgs, environment, ... }: {
  imports = [ ../common.nix ];

  services.nomad = {
    enable = true;
    enableDocker = true;

    settings = {
      datacenter = "skynet";

      server = {
        enabled = true;
        bootstrap_expect = 3;

        server_join = {
          retry_join = [ "192.168.1.251" ];
          retry_interval = "15s";
          retry_max = 40;
        };
      };

      client = { enabled = true; };
    };
  };

  networking.firewall.enable = false;
}
