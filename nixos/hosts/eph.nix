{
  environment,
  self,
  util,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  roles.tailscale.enable = true;

  roles.workstation.enable = true;

  networking.firewall.enable = true;

  systemd.network.networks = util.mkClusterNetworks self;

  # Do not enable libvirtd inside of test VM, the inner virtual bridge
  # routing to the outer virtual network, due to using the same IP range.
  virtualisation.libvirtd.enable = environment == "prod";

  roles.upsmon = {
    enable = true;
    wave = 1;
  };
}
