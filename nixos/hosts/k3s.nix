{ config, pkgs, lib, environment, catalog, self, util, ... }: {
  imports = [ ../common.nix ];

  roles.tailscale.enable = lib.mkForce false;

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";

  services.k3s =
    let
      leader = catalog.k3s.leader;

      isLeader = leader == self;
    in
    {
      enable = true;

      # Enables embedded etcd on leader node.
      clusterInit = isLeader;
      serverAddr = lib.mkIf (! isLeader) "https://${leader.ip.priv}:6443";

      tokenFile = config.age.secrets.k3s-token.path;
    };

  networking.firewall.enable = false;

  age.secrets = {
    k3s-token.file = ../secrets/k3s-token.age;
  };
}
