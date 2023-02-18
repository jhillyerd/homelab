{ pkgs, lib, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.cluster-volumes.enable = true;

  roles.consul = {
    enableClient = true;
    retryJoin = catalog.consul.servers;
  };

  roles.gateway-online.addr = "192.168.1.1";

  networking.firewall.enable = false;
}
