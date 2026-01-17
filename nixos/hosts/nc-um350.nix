{
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  roles.dns.bind.enable = true;
  roles.dns.bind.serveLocalZones = false;

  roles.consul = {
    enableServer = true;

    client = {
      enable = true;
      connect = true;
    };
  };

  roles.nomad = {
    enableClient = true;
    enableServer = true;
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
