{ config, pkgs, lib, environment, catalog, self, util, ... }: {
  imports = [ ../common.nix ];

  roles.tailscale.enable = lib.mkForce false;

  systemd.network.networks = util.mkClusterNetworks self;
  roles.gateway-online.addr = "192.168.1.1";

  services.k3s = {
    enable = true;
  };

  networking.firewall.enable = false;
}
