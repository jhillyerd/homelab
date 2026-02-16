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

  services.chrony = {
    enable = true;
    servers = [
      "0.nixos.pool.ntp.org"
      "1.nixos.pool.ntp.org"
      "2.nixos.pool.ntp.org"
      "3.nixos.pool.ntp.org"
    ];
    extraConfig = ''
      allow
    '';
  };

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
