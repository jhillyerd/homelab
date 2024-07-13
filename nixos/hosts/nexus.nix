{ self, util, ... }: {
  imports = [ ../common.nix ../common/onprem.nix ];

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";

  roles.dns.bind.enable = true;
  roles.dns.bind.serveLocalZones = true;

  roles.tailscale.enable = true;

  networking.firewall.enable = false;
}
