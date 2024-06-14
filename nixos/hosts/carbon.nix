{ lib, ... }: {
  imports = [ ../common.nix ];

  # roles.tailscale.enable = true;

  roles.workstation.enable = true;
  # roles.workstation.graphical = true;

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  virtualisation.libvirtd.enable = true;

  system.stateVersion = lib.mkOverride 0 "24.05";
}
