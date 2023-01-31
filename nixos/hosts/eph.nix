{ config, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  roles.workstation.enable = true;
  roles.workstation.graphical = false;

  networking.firewall.enable = true;

  # Do not enable libvirtd inside of test VM, the inner virtual bridge
  # routing to the outer virtual network, due to using the same IP range.
  virtualisation.libvirtd.enable = environment == "prod";
}
