{ config, lib, ... }:
{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
    timeout = 10;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c6fb5461-1de7-4764-b313-2de767ccb836";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/5C34-C3D2";
    fsType = "vfat";
  };

  swapDevices = [ ];

  networking = {
    useDHCP = false;
    interfaces.enp6s0.useDHCP = true;
  };

  services.fstrim.enable = true;
  services.hw-gauge-daemon.enable = true;

  # nvidia graphics card setup.
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    powerManagement.enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  fonts.fontconfig = {
    antialias = true;
    subpixel.rgba = "rgb";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
