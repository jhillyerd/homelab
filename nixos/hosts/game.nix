{
  config,
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
    backend = "docker";

    containers = {
      theforest = {
        image = "jammsen/the-forest-dedicated-server:latest";
        hostname = "theforest";
        ports = [
          "8766:8766/udp"
          "27015:27015/udp"
          "27016:27016/udp"
        ];
        volumes = [ "/data/theforest:/theforest" ];
        environmentFiles = [ config.age.secrets."theforest-environment".path ];
      };
    };
  };

  networking.firewall.enable = true;

  roles.upsmon = {
    enable = true;
    wave = 1;
  };

  age.secrets = {
    "theforest-environment" = {
      file = ../secrets/theforest-environment.age;
    };
  };
}
