# Hyper-V Guest Hardware
{ lib, ... }: {
  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  # Hardware Configuration
  boot.initrd.availableKernelModules = [ "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.growPartition = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  swapDevices = [ ];

  virtualisation.hypervGuest.enable = true;

  nix.maxJobs = lib.mkDefault 2;
}
