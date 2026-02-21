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

  roles.dns.bind = {
    enable = true;
    serveLocalZones = true;
  };

  roles.consul.enableServer = true;
  roles.nomad.enableServer = true;

  services.nginx = {
    enable = true;

    # Foward NUT (UPS) traffic to NAS.
    streamConfig = ''
      server {
        listen *:3493;
        proxy_pass mininas.home.arpa:3493;
      }
    '';
  };

  networking.firewall.enable = false;

  roles.upsmon = {
    enable = true;
    wave = 3;
  };
}
