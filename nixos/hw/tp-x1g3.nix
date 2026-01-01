{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6dc82f20-f212-4d00-a910-7b75934e7596";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-4923c6cb-e919-458b-bdb9-f972ddd162a6".device =
    "/dev/disk/by-uuid/4923c6cb-e919-458b-bdb9-f972ddd162a6";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F480-2E4D";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/7adc1774-c80c-4244-8d2c-debceceb34b0";
      randomEncryption.enable = true;
    }
  ];

  networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # nvidia graphics card setup.
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true; # for udev events
    powerManagement.enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.trackpoint.device = "TPPS/2 Elan TrackPoint";

  services.fstrim.enable = true;
  services.power-profiles-daemon.enable = true;
  services.throttled.enable = true;

  services.libinput.touchpad = {
    accelSpeed = "0.3";
    clickMethod = "clickfinger";
    naturalScrolling = true;
    tapping = true;
  };

  environment.etc."libinput/local-overrides.quirks".text = ''
    [Touchpad pressure override]
    MatchUdevType=touchpad
    MatchName=Synaptics TM3625-010
    MatchDMIModalias=dmi:*svnLENOVO:*:pvrThinkPadX1ExtremeGen3*
    AttrPressureRange=10:8
  '';

  fonts.fontconfig = {
    antialias = true;
    subpixel.rgba = "rgb";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.firmware = [ pkgs.linux-firmware ];
}
