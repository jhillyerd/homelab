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
            type = path;
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
        options = [ "bind" ];
      };
    in
    mkIf (length (attrNames cfg.binds) > 0) {
      systemd.services.nfs-bind-init = {
        script = lib.concatStringsSep "\n" (mapAttrsToList setupDir cfg.binds);
        wantedBy = [ "remote-fs.target" ];
        after = [ "remote-fs.target" ];
      };

      # Create fstab bindings; e.g. mount /data/grafana at /var/lib/grafana
      fileSystems = (mapAttrs' fsBindEntry cfg.binds)
        // {
          # Mount NFS volume
          "${cfg.mountPoint}" = {
            device = cfg.nfsPath;
            fsType = "nfs";
          };
        };
    };
}
