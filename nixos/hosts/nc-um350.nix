{ config, lib, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.dns.enable = true;
  roles.dns.serveLocalZones = true;

  roles.cluster-volumes.enable = true;

  roles.consul = {
    enableServer = true;
    retryJoin = catalog.consul.servers;

    client.enable = true;
  };

  roles.nomad = {
    enableClient = true;
    enableServer = true;
    allocDir = "/data/nomad-alloc";

    retryJoin = catalog.nomad.servers;

    hostVolumes = lib.genAttrs catalog.nomad.skynas-host-volumes
      (name: {
        path = "/mnt/skynas/${name}";
        readOnly = false;
      }) // {
      "docker-sock-ro" = {
        path = "/var/run/docker.sock";
        readOnly = true;
      };
    };
  };

  roles.gateway-online.addr = "192.168.1.1";

  virtualisation.docker.extraOptions = "--data-root /data/docker";

  networking.firewall.enable = false;
}
