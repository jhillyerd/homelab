{
  config,
  lib,
  catalog,
  environment,
  ...
}:
let
  cfg = config.roles.cluster-volumes;
in
{
  options.roles.cluster-volumes = {
    enable = lib.mkEnableOption "Enable NFS mount of catalog cluster volumes";
  };

  config = lib.mkIf cfg.enable {
    fileSystems = {
      "/mnt/skynas" = {
        device = "192.168.1.20:/volume1/cluster_${environment}";
        fsType = "nfs";
        options = [
          "x-systemd.automount"
          "noauto"
        ];
      };
    };

    systemd.services.host-volume-init = {
      # Create host volume dirs.
      script = lib.concatStringsSep "\n" (
        map (name: ''
          path=${lib.escapeShellArg "/mnt/skynas/${name}"}
          if [ ! -e "$path" ]; then
            mkdir -p "$path"
            chmod 770 "$path"
          fi
        '') catalog.nomad.skynas-host-volumes
      );

      wants = [
        "network-online.target"
        "remote-fs.target"
      ];
      after = [
        "network-online.target"
        "remote-fs.target"
      ];
      wantedBy = [ "nomad.service" ];
      before = [ "nomad.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
}
