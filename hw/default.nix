# Hardware templates
{ dnsDomain }:
{
  # KVM/QEMU Guest Hardware
  kvmGuest = { name }: { config, pkgs, lib, ... }:
  {
    # NixOps deployment info
    deployment.targetHost = name + "." + dnsDomain;

    # Hardware configuration
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/sda";

    networking.hostName = name;
    networking.interfaces.ens3.useDHCP = true;

    services.openssh.enable = true;
    services.openssh.permitRootLogin = "yes";

    time.timeZone = "US/Pacific";

    system.stateVersion = "20.03";

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
