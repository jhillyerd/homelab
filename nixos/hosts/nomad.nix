{ config, pkgs, environment, ... }: {
  imports = [ ../common.nix ];

  services.nomad = {
    enable = true;
    enableDocker = true;

    settings = {
      server = {
        enabled = true;
        bootstrap_expect = 1;
      };

      client = { enabled = true; };
    };
  };

  networking.firewall.enable = false;
}
