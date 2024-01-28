# A scratch host for building up new service configurations.
{ config, pkgs, lib, self, catalog, util, ... }: {
  imports = [ ../common.nix ];

  systemd.network.networks = util.mkClusterNetworks self;

  networking.firewall.enable = false;
}
