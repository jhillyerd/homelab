{ ... }:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  roles.tailscale.enable = true;

  roles.gui-sway.enable = true;
  roles.workstation.enable = true;
  roles.microvm-host.enable = true;

  # For Raspberry Pi builds.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.firewall.enable = false;

  # Do not enable libvirtd inside of test VM, the inner virtual bridge
  # routing to the outer virtual network, due to using the same IP range.
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.daemon.settings = {
    data-root = "/data/docker";
  };

  # For Windows dual-boot.
  time.hardwareClockInLocalTime = true;
}
