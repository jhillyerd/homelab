{
  lib,
  config,
  catalog,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  roles.cluster-volumes.enable = true;

  roles.consul = {
    retryJoin = catalog.consul.servers;

    client = {
      enable = true;
      connect = true;
    };
  };

  roles.nomad = {
    enableClient = true;

    retryJoin = catalog.nomad.servers;

    hostVolumes =
      lib.genAttrs catalog.nomad.skynas-host-volumes (name: {
        path = "/mnt/skynas/${name}";
        readOnly = false;
      })
      // {
        "docker-sock-ro" = {
          path = "/var/run/docker.sock";
          readOnly = true;
        };
      };

    # USB plugin doesn't seem to work.
    # usb = {
    #   enable = true;
    #   includedVendorIds = [
    #     1624 # 0x0658, Aeotec
    #   ];
    # };

    client = {
      meta = {
        # Envoy built with gperftools
        # https://github.com/envoyproxy/envoy/issues/23339#issuecomment-1290509732
        "connect.sidecar_image" = "thegrandpkizzle/envoy:1.24.0";
      };
    };
  };

  roles.gateway-online.addr = "192.168.1.1";

  networking.firewall.enable = false;

  networking.wireless = {
    enable = true;
    environmentFile = config.age.secrets.wifi-env.path;
    networks.SKYNET.psk = "@SKYNET_PSK@";
  };
}
