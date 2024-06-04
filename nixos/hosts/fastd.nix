{ config, self, util, ... }: {
  imports = [ ../common.nix ];

  boot.supportedFilesystems = [ "zfs" ];

  # Listed extra pools must be available during boot.
  boot.zfs.extraPools = [ "fast1" ];

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    dataDir = "/fast1/database/postgresql/${config.services.postgresql.package.psqlSchema}";

    authentication = ''
      host all all all scram-sha-256
    '';

    ensureDatabases = [ "root" "gitea" ];
    ensureUsers = [
      {
        name = "root";
        ensureDBOwnership = true;
        ensureClauses.superuser = true;
        ensureClauses.login = true;
      }
      {
        name = "gitea";
        ensureDBOwnership = true;
        ensureClauses."inherit" = true;
        ensureClauses.login = true;
      }
    ];
  };

  services.openiscsi = {
    enable = true;
    enableAutoLoginOut = true;
    name = "iqn.1999-11.org.bytemonkey:fastd";
  };

  # Import iSCSI ZFS pools.
  systemd.services.zfs-import-backup1 = {
    # Give iSCSI time to login to NAS.
    preStart = "/run/current-system/sw/bin/sleep 5";

    script =
      let
        zpoolcmd = "/run/current-system/sw/bin/zpool";
        pool = "backup1";
      in
      ''
        if ! ${zpoolcmd} list ${pool} >/dev/null 2>&1; then
          ${zpoolcmd} import ${pool}
        fi
      '';

    wantedBy = [ "multi-user.target" ];
    requires = [ "iscsi.service" ];
    after = [ "iscsi.service" ];
    serviceConfig.Type = "oneshot";
  };

  services.syncoid = {
    enable = true;
    interval = "minutely";

    localSourceAllow = [
      "bookmark"
      "hold"
      "mount" # added
      "send"
      "snapshot"
      "destroy"
    ];

    localTargetAllow = [
      "change-key"
      "compression"
      "create"
      "destroy" # added
      "mount"
      "mountpoint"
      "receive"
      "rollback"
    ];

    # Volumes to backup.
    commands."fast1/database".target = "backup1/database";
  };

  # Collect snapshot stats.
  roles.telegraf.zfs = true;

  systemd.network.networks = util.mkClusterNetworks self;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    config.services.postgresql.settings.port
  ];
}
