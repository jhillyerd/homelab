{
  config,
  catalog,
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

  services.k3s = {
    enable = true;
    disableAgent = true;

    serverAddr = "https://${catalog.k3s.leader.ip.priv}:6443";
    extraFlags = "--egress-selector-mode pod";

    tokenFile = config.age.secrets.k3s-token.path;
  };

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

  age.secrets = {
    k3s-token.file = ../secrets/k3s-token.age;
  };

  networking.firewall.enable = false;

  roles.upsmon = {
    enable = true;
    wave = 3;
  };
}
