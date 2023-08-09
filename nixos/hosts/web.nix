{ config, pkgs, lib, environment, catalog, ... }: {
  imports = [ ../common.nix ];

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

  roles.gateway-online.addr = "192.168.1.1";

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
    email = catalog.cf-api.user;
    records = [ "home.bytemonkey.org" ];
  };

  systemd.services.cfdyndns = {
    startAt = lib.mkForce "*:07:00";
    script = lib.mkForce ''
      export CLOUDFLARE_APITOKEN="$(cat $CREDENTIALS_DIRECTORY/api.key)"
      ${pkgs.cfdyndns}/bin/cfdyndns
    '';

    serviceConfig.LoadCredential =
      "api.key:${config.age.secrets.cloudflare-dns-api.path}";

    after = [ "network-online.target" ];
  };

  age.secrets = {
    cloudflare-dns-api.file = ../secrets/cloudflare-dns-api.age;
  };
}
