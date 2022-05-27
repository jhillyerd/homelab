{ config, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.dns.enable = true;
  roles.dns.serveLocalZones = true;

  roles.nomad = {
    enableClient = true;
    enableServer = true;
    allocDir = "/data/nomad-alloc";

    retryJoin = with catalog.nodes;
      [ nexus.ip.priv nc-um350-1.ip.priv nc-um350-2.ip.priv ];

    # TODO: mapify, and create dir if missing.
    hostVolumes = {
      gitea-storage = {
        path = "/mnt/skynas/gitea-storage";
        readOnly = false;
      };

      grafana-storage = {
        path = "/mnt/skynas/grafana-storage";
        readOnly = false;
      };
    };
  };

  roles.gateway-online.addr = "192.168.1.1";

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
