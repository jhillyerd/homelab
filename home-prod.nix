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
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" =
        { device = "/dev/disk/by-uuid/2fe3422d-f18a-46d9-884f-f6f0251d7c99";
        fsType = "ext4";
      };

      swapDevices =
        [ { device = "/dev/disk/by-uuid/f5ed7fa7-8fe0-448d-98e1-3545f517100c"; }
      ];

      nix.maxJobs = lib.mkDefault 2;
    };
}
