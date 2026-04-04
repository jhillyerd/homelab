{ ... }:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  roles.gui-plasma.enable = true;
  roles.workstation.enable = true;

  roles.tailscale.enable = true;

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  virtualisation.libvirtd.enable = true;

  roles.upsmon = {
    enable = true;
    wave = 2;
  };
}
