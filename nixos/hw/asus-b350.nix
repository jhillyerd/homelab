{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "jc42"
    "kvm-amd"
  ];
  boot.extraModulePackages = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    useDHCP = false;
    interfaces.enp4s0.useDHCP = true;
  };

  services.fstrim.enable = true;

  # nvidia graphics card setup.
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    powerManagement.enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # expose GPU to docker containers.
  hardware.nvidia-container-toolkit.enable = true;

  # Cap the GPU (RTX 3090, 350W default) at 300W. The limit resets on every
  # reboot, so apply it via a oneshot service once the driver is loaded.
  systemd.services.nvidia-power-limit = {
    description = "NVIDIA GPU power limit";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ]; # udev must load the nvidia modules first
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ config.hardware.nvidia.package.bin ];
    script = "nvidia-smi -pl 300";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6FF4-8DB6";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.firmware = [ pkgs.linux-firmware ];
}
