{
  config,
  pkgs,
  self,
  util,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  boot.supportedFilesystems = [ "zfs" ];

  # Listed extra pools must be available during boot.
  boot.zfs.extraPools = [ "fast1" ];

  services.postgresql = {
    package = pkgs.postgresql_16;

    enable = true;
    enableTCPIP = true;
    dataDir = "/fast1/database/postgresql/${config.services.postgresql.package.psqlSchema}";

    authentication = ''
      host all all all scram-sha-256
    '';
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
    commands."fast1/database" = {
      target = "syncoid@mininas.home.arpa:tank/replicas/fastd/database";
      sshKey = config.age.secrets."syncoid-ssh-key".path;
      extraArgs = [
        "--compress=zstd-fast"
      ];
    };

    service.after = [ "zfs-import-backup1.service" ];
  };

  # Collect snapshot stats.
  roles.telegraf.zfs = true;

  systemd.network.networks = util.mkClusterNetworks self;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ config.services.postgresql.settings.port ];

  age.secrets = {
    syncoid-ssh-key = {
      file = ../secrets/syncoid-ssh-key.age;
      owner = "syncoid";
    };
  };

  roles.upsmon = {
    enable = true;
    wave = 2;
  };
}
