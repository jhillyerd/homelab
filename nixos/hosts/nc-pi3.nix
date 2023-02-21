{ pkgs, lib, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.cluster-volumes.enable = true;

  roles.consul = {
    enableClient = true;
    retryJoin = catalog.consul.servers;
  };

  roles.nomad = {
    enableClient = true;

    retryJoin = catalog.nomad.servers;

    hostVolumes = lib.genAttrs catalog.nomad.skynas-host-volumes
      (name: {
        path = "/mnt/skynas/${name}";
        readOnly = false;
      }) // {
      "docker-sock-ro" = {
        path = "/var/run/docker.sock";
        readOnly = true;
      };
    };

    usb = {
      enable = true;
      includedVendorIds = [ "0x0658" ];
    };
  };

  roles.gateway-online.addr = "192.168.1.1";

  networking.firewall.enable = false;
}
