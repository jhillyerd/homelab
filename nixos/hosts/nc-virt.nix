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

  roles.consul = {
    client = {
      enable = true;
      connect = true;
    };
  };

  roles.nomad = {
    enableClient = true;
    client.allocDir = "/data/nomad-alloc";
  };

  roles.telegraf.nomad = true;

  roles.gateway-online.addr = "192.168.1.1";

  virtualisation.docker.daemon.settings = {
    data-root = "/data/docker";
  };

  networking.firewall.enable = false;

  roles.upsmon = {
    enable = true;
    wave = 1;
  };
}
