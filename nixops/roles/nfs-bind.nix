# nfs-bind allows the top-level directories of a single remote NFS volume to
# be mounted to various portions of the local filesystem.  nfs-bind will
# create the top-level directories after the NFS volume is mounted.
#
# Example:
#   nfs.example.com:/exports/files is mounted to /data;
#   /data/grafana is then bind-mounted to /var/lib/grafana
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.nfs-bind;
in
{
  options.roles.nfs-bind = {
    nfsPath = mkOption {
      type = types.str;
      description = "Remote NFS device/path";
      example = "nfs.example.com:/exports/files";
    };

    mountPoint = mkOption {
      type = types.path;
      description = "Where to mount NFS filesystem";
      default = "/data";
    };

    binds = mkOption {
      type = with types; attrsOf (submodule {
        options = {
          path = mkOption {
            type = nullOr path;
            description = "Where to mount this binding, or null";
            default = null;
            example = "/var/lib/grafana";
          };

          user = mkOption {
            type = str;
            default = "root";
          };

          group = mkOption {
            type = str;
            default = "root";
          };

          mode = mkOption {
            type = str;
            default = "0755";
          };
        };
      });
      description = "Bound directories";
      default = {};
    };

    before = mkOption {
      type = types.listOf types.str;
      description = "Delay these systemd units until the binds are configured.";
      default = [];
    };
  };

  config =
    let
      setupDir = name: bind: ''
        mkdir -p "${cfg.mountPoint}/${name}"
        chown ${bind.user}:${bind.group} "${cfg.mountPoint}/${name}"
        chmod ${bind.mode} "${cfg.mountPoint}/${name}"
      '';

      fsBindEntry = name: bind: nameValuePair bind.path {
        device = "${cfg.mountPoint}/${name}";
        options = [ "bind" "_netdev" ];
        noCheck = true;
      };
    in
    mkIf (length (attrNames cfg.binds) > 0) {
      systemd.services.nfs-bind-init = {
        script = lib.concatStringsSep "\n" (mapAttrsToList setupDir cfg.binds);
        wantedBy = [ "multi-user.target" ];
        after = [ "remote-fs.target" ];
        before = cfg.before;
        serviceConfig = {
          Type = "oneshot";
        };
      };

      # Create fstab bindings; e.g. mount /data/grafana at /var/lib/grafana
      fileSystems = (mapAttrs' fsBindEntry
        (filterAttrs (name: bind: bind.path != null) cfg.binds))
        // {
          # Mount NFS volume
          "${cfg.mountPoint}" = {
            device = cfg.nfsPath;
            fsType = "nfs";
          };
        };
    };
}
