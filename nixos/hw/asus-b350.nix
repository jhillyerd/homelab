{ config, lib, pkgs, modulesPath, ... }: {
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "jc42" "kvm-amd" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    timeout = 10;
  };

  # For Raspberry Pi builds.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking = {
    useDHCP = false;
    hostName = "fractal";
    interfaces.enp4s0.useDHCP = true;
  };

  services.fstrim.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
