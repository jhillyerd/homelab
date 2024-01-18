{ config, pkgs, lib, environment, catalog, self, util, ... }: {
  imports = [ ../common.nix ];

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";

  roles.dns.bind.enable = true;
  roles.dns.bind.serveLocalZones = true;

  roles.consul = {
    enableServer = true;
    retryJoin = catalog.consul.servers;
  };

  roles.nomad = {
    enableServer = true;
    retryJoin = catalog.nomad.servers;
  };

  roles.tailscale.exitNode = true;

  networking.firewall.enable = false;
}
