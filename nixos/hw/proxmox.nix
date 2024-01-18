# Proxmox VE Guest Hardware
{ lib, modulesPath, ... }: {
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # We don't always know the interface name on QEMU.
  networking.useDHCP = lib.mkDefault true;

  # Hardware configuration
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    initrd.availableKernelModules = [ "uas" ];
    initrd.kernelModules = [ ];

    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [ ];

  nix.settings.max-jobs = lib.mkDefault 2;

  services.qemuGuest.enable = true;
}
