{ config, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.nomad = {
    enableClient = true;
    enableServer = true;
    allocDir = "/data/nomad-alloc";

    consulBind = catalog.tailscale.interface;
    retryJoin = with catalog.nodes; [ nexus.ip nc-um350-1.ip nc-um350-2.ip ];
  };

  virtualisation.docker.extraOptions = "--data-root /data/docker";

  networking.firewall.enable = false;
}
