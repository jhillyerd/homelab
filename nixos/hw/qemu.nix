# QEMU Guest Hardware
{ lib, modulesPath, ... }: {
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  # We don't always know the interface name on QEMU.
  networking.useDHCP = true;

  # Hardware configuration
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules =
    [ "ahci" "xhci_pci" "virtio_pci" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 2;
}
