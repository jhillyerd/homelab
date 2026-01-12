{ environment, lib, ... }:
{
  # TODO remove after homelab catches up.
  system.stateVersion = lib.mkForce "25.11";

  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  roles.gui-sway.enable = true;
  roles.workstation.enable = true;

  roles.tailscale.enable = true;

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  virtualisation.libvirtd.enable = environment == "prod";
}
