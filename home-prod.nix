{
  webserver =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "webserver.skynet.local";

      boot.loader.grub.enable = true;
      boot.loader.grub.version = 2;
      boot.loader.grub.device = "/dev/sda";

      networking.hostName = "webserver";
      networking.interfaces.ens3.useDHCP = true;

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";

      time.timeZone = "US/Pacific";

      system.stateVersion = "20.03";

      # HW config
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
