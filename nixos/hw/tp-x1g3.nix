{ config, lib, ... }:
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

  boot.initrd.luks.devices."luks-4923c6cb-e919-458b-bdb9-f972ddd162a6".device = "/dev/disk/by-uuid/4923c6cb-e919-458b-bdb9-f972ddd162a6";

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

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  services.fstrim.enable = true;

  # nvidia graphics card setup.
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    dpi = 96;
    enableCtrlAltBackspace = true;

    xrandrHeads = [
      {
        output = "DP-2";
        primary = true;
      }
    ];

    # Pipeline prevents screen tearing.
    screenSection = ''
      Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option "AllowIndirectGLXProtocol" "off"
      Option "TripleBuffer" "on"
    '';
  };

  fonts.fontconfig = {
    antialias = true;
    subpixel.rgba = "rgb";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.nvidia.modesetting.enable = true; # for udev events
  hardware.nvidia.open = true;
}
