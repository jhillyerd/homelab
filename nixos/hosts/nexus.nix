{ config, pkgs, lib, environment, catalog, ... }: {
  imports = [ ../common.nix ];

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

  roles.gateway-online.addr = "192.168.1.1";

  roles.tailscale.exitNode = true;

  networking.firewall.enable = false;
}
