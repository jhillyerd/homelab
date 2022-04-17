{ config, pkgs, environment, ... }: {
  imports = [ ../common.nix ];

  # Enable nix flakes, not yet stable.
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "james" ];
  };

  roles.workstation.enable = true;
  roles.workstation.graphical = true;

  networking.firewall.enable = false;

  # Do not enable libvirtd inside of test VM, the inner virtual bridge
  # routing to the outer virtual network, due to using the same IP range.
  virtualisation.libvirtd.enable = environment == "prod";
}
