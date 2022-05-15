{ config, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.nomad = {
    enableClient = true;
    enableServer = true;
    allocDir = "/data/nomad-alloc";

    retryJoin = with catalog.nodes; [ nexus.ip nc-um350-1.ip nc-um350-2.ip ];

    hostVolumes = {
      grafana-storage = {
        path = "/mnt/skynas/grafana-storage";
        readOnly = false;
      };
    };
  };

  fileSystems = {
    "/mnt/skynas" = {
      device = "192.168.1.20:/volume1/cluster_${environment}";
      fsType = "nfs";
    };
  };

  virtualisation.docker.extraOptions = "--data-root /data/docker";

  networking.firewall.enable = false;
}
