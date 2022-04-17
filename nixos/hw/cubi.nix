# MSI Cubi Mini PC
{ lib, ... }: {
  # Hardware configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.interfaces.enp2s0.useDHCP = true;

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "nct6775" "coretemp" ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
