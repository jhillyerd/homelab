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

  # nvidia graphics card setup.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.package =
    config.boot.kernelPackages.nvidiaPackages.stable;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
