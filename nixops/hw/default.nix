# Hardware templates
{
  # MSI Cubi Mini PC
  msiCubi =
    { name, ip }:
    { config, pkgs, lib, ... }:
    {
      # NixOps deployment info
      deployment.targetHost = ip;

      # Hardware configuration
      boot.loader.grub.enable = true;
      boot.loader.grub.version = 2;
      boot.loader.grub.device = "/dev/sda";

      networking.hostName = name;
      networking.interfaces.enp2s0.useDHCP = true;

      boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" ];
      boot.kernelModules = [ "kvm-intel" "nct6775" "coretemp" ];

      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    };

  # KVM/QEMU Guest Hardware
  kvmGuest =
    { name, ip }:
    { config, pkgs, lib, ... }:
    {
      # NixOps deployment info
      deployment.targetHost = ip;

      # Hardware configuration
      boot.loader.grub.enable = true;
      boot.loader.grub.version = 2;
      boot.loader.grub.device = "/dev/sda";

      networking.hostName = name;
      networking.interfaces.ens3.useDHCP = true;

      boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod" ];
      boot.kernelModules = [ "kvm-intel" ];

      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

      nix.maxJobs = lib.mkDefault 2;
    };
}
