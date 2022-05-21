{ config, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.nomad = {
    enableClient = true;
    enableServer = true;
    allocDir = "/data/nomad-alloc";

    retryJoin = with catalog.nodes;
      [ nexus.ip.priv nc-um350-1.ip.priv nc-um350-2.ip.priv ];

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
      options = [ "x-systemd.automount" "noauto" ];
    };
  };

  virtualisation.docker.extraOptions = "--data-root /data/docker";

  networking.firewall.enable = false;
}
