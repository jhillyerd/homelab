{
  config,
  lib,
  environment,
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

  # Web services accessed via tailnet.
  roles.tailscale = {
    enable = true;
    exitNode = true;
  };

  roles.nfs-bind = {
    nfsPath = "192.168.1.20:/volume1/web_${environment}";

    binds = {
      "authelia" = {
        user = "0";
        group = "0";
        mode = "0770";
      };
    };

    before = [ "podman-authelia.service" ];
  };

  # Configures traefik and homesite roles from service catalog.
  roles.websvc = {
    enable = true;

    internalDomain = "bytemonkey.org";
    externalDomain = "x.bytemonkey.org";

    cloudflareDnsApiTokenFile = config.age.secrets.cloudflare-dns-api.path;

    services = catalog.services;
    layout = catalog.layout;
  };

  virtualisation.oci-containers.containers = {
    authelia = {
      image = "authelia/authelia:4.37.5";
      ports = [ "${toString catalog.authelia.port}:9091" ];
      volumes = [ "/data/authelia:/config" ];
    };
  };

  services.cfdyndns = {
    enable = true;
    records = [ "home.bytemonkey.org" ];

    email = catalog.cf-api.user;
    apiTokenFile = config.age.secrets.cloudflare-dns-api.path;
  };

  systemd.services.cfdyndns = {
    startAt = lib.mkForce "*:07:00";

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  age.secrets = {
    cloudflare-dns-api.file = ../secrets/cloudflare-dns-api.age;
  };

  roles.upsmon = {
    enable = true;
    wave = 1;
  };
}
