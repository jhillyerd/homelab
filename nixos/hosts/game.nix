{
  self,
  util,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";

  virtualisation.oci-containers = {
    backend = "docker"; # https://github.com/mornedhels/enshrouded-server/issues/103

    containers = {
      enshrouded = {
        image = "mornedhels/enshrouded-server:latest";
        hostname = "enshrouded";
        ports = [
          "15637:15637/udp" # Enshrouded
        ];
        volumes = [ "/data/enshrouded:/opt/enshrouded" ];
        environment = {
          SERVER_NAME = "Enshrouded by Cuteness_v3_FINAL";
          SERVER_ENABLE_TEXT_CHAT = "true";
          UPDATE_CRON = "37 * * * *";
          UPDATE_CHECK_PLAYERS = "true";
          BACKUP_CRON = "*/30 * * * *";
          BACKUP_MAX_COUNT = "48";
        };
      };
    };
  };

  networking.firewall.enable = true;

  roles.upsmon = {
    enable = true;
    wave = 1;
  };
}
