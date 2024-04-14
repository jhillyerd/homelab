# A scratch host for building up new service configurations.
{ self, util, ... }: {
  imports = [ ../common.nix ];

  systemd.network.networks = util.mkClusterNetworks self;

  networking.firewall.enable = false;

  ### Temporary configuration below.
}
