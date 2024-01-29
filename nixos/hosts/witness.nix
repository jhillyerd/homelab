{ config, pkgs, lib, environment, catalog, self, util, ... }: {
  imports = [ ../common.nix ];

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";

  services.k3s = {
    enable = true;
    disableAgent = true;

    serverAddr = "https://${catalog.k3s.leader.ip.priv}:6443";

    tokenFile = config.age.secrets.k3s-token.path;
  };

  age.secrets = {
    k3s-token.file = ../secrets/k3s-token.age;
  };

  networking.firewall.enable = false;
}
