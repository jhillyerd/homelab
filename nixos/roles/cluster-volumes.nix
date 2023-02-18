{ config, pkgs, lib, catalog, environment, ... }:
with lib;
let cfg = config.roles.cluster-volumes;
in
{
  options.roles.cluster-volumes = {
    enable = mkEnableOption "Enable NFS mount of catalog cluster volumes";
  };

  config = mkIf cfg.enable {
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
        catalog.nomad.skynas-host-volumes);

      after = [ "remote-fs.target" ];
      wantedBy = [ "nomad.service" ];
      before = [ "nomad.service" ];
      serviceConfig = { Type = "oneshot"; };
    };
  };
}
