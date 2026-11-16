{ ... }:
{
  imports = [
    ../common
    ../common/onprem.nix
  ];

  roles.tailscale.enable = true;

  roles.gui-sway.enable = true;
  roles.workstation.enable = true;
  roles.gaming.enable = true;

  networking.firewall.enable = false;
}
