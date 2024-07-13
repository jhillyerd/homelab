{ config, catalog, self, util, ... }: {
  imports = [ ../common.nix ../common/onprem.nix ];

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";

  roles.consul = {
    enableServer = true;
    retryJoin = catalog.consul.servers;
  };

  roles.nomad = {
    enableServer = true;
    retryJoin = catalog.nomad.servers;
  };

  services.k3s = {
    enable = true;
    disableAgent = true;

    serverAddr = "https://${catalog.k3s.leader.ip.priv}:6443";
    extraFlags = "--egress-selector-mode pod";

    tokenFile = config.age.secrets.k3s-token.path;
  };

  age.secrets = {
    k3s-token.file = ../secrets/k3s-token.age;
  };

  networking.firewall.enable = false;
}
