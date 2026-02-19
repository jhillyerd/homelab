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

  virtualisation.oci-containers = {
    containers = {
      agent0 = {
        image = "agent0ai/agent-zero:v0.9.8";
        hostname = "agent0";
        ports = [
          "80:80/tcp"
        ];
        volumes = [ "/data/agent0:/a0/usr" ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/agent0 0750 root root - -"
  ];

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";
  networking.firewall.enable = true;

  roles.upsmon = {
    enable = true;
    wave = 1;
  };
}
