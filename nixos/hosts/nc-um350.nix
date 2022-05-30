{ config, lib, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.dns.enable = true;
  roles.dns.serveLocalZones = true;

  roles.nomad = {
    enableClient = true;
    enableServer = true;
    allocDir = "/data/nomad-alloc";

    retryJoin = with catalog.nodes;
      [ nexus.ip.priv nc-um350-1.ip.priv nc-um350-2.ip.priv ];

    hostVolumes = lib.genAttrs catalog.skynas-nomad-host-volumes
      (name: {
        path = "/mnt/skynas/${name}";
        readOnly = false;
      });
  };

  roles.gateway-online.addr = "192.168.1.1";

  fileSystems = {
    "/mnt/skynas" = {
      device = "192.168.1.20:/volume1/cluster_${environment}";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" ];
    };
  };

  systemd.services.host-volume-init = {
    # Create host volume dirs.
    script = lib.concatStringsSep "\n" (map
      (name: ''
        path=${lib.escapeShellArg "/mnt/skynas/${name}"}
        if [ ! -e "$path" ]; then
          mkdir -p "$path"
          chmod 770 "$path"
        fi
      '')
      catalog.skynas-nomad-host-volumes);

    after = [ "remote-fs.target" ];
    wantedBy = [ "nomad.service" ];
    before = [ "nomad.service" ];
    serviceConfig = { Type = "oneshot"; };
  };

  virtualisation.docker.extraOptions = "--data-root /data/docker";

  networking.firewall.enable = false;
}
