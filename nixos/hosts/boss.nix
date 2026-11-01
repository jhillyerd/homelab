{ self, util, ... }:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  roles.workstation.enable = true;

  roles.tailscale.enable = true;
  systemd.network.networks = util.mkClusterNetworks self;
  networking.firewall.enable = false;

  fileSystems."/home" = {
    device = "/dev/disk/by-label/home";
    fsType = "ext4";
  };

  roles.upsmon = {
    enable = true;
    wave = 1;
  };
}
