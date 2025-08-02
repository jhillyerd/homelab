{
  description = "VM deployment target base images";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-generators,
    }:
    let
      inherit (nixpkgs) lib;

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      baseModule =
        { ... }:
        {
          services.openssh = {
            enable = true;
            settings.PermitRootLogin = "yes";
          };

          time.timeZone = "US/Pacific";

          users.users.root.openssh.authorizedKeys.keys = lib.splitString "\n" (
            builtins.readFile ../authorized_keys.txt
          );

          # Display the IP address at the login prompt.
          environment.etc."issue.d/ip.issue".text = ''
            This is a base image.
            IPv4: \4
          '';
          networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";
        };

      qemuModule =
        { ... }:
        {
          boot.kernelParams = [ "console=ttyS0" ];

          services.qemuGuest.enable = true;
        };

      proxmoxModule =
        { modulesPath, ... }:
        {
          imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

          boot.kernelParams = [ "console=ttyS0" ];

          networking.useDHCP = false;

          services.cloud-init = {
            enable = true;
            network.enable = true;

            settings = {
              system_info = {
                distro = "nixos";
                network.renderers = [ "networkd" ];
              };

              ssh_pwauth = true;

              # Network stage.
              cloud_init_modules = [
                "migrator"
                "seed_random"
                "growpart"
                "resizefs"
                "set_hostname"
              ];

              # Config stage.
              cloud_config_modules = [
                "disk_setup"
                "mounts"
                "set-passwords"
                "ssh"
              ];
            };
          };

          services.qemuGuest.enable = true;
        };
    in
    {
      packages.${system} = {
        hyperv = nixos-generators.nixosGenerate {
          inherit pkgs;
          modules = [ baseModule ];
          format = "hyperv";
        };

        libvirt = nixos-generators.nixosGenerate {
          inherit pkgs;
          modules = [
            baseModule
            qemuModule
          ];
          format = "qcow";
        };

        proxmox = nixos-generators.nixosGenerate {
          inherit pkgs;
          modules = [
            baseModule
            proxmoxModule
          ];
          format = "qcow";
        };
      };
    };
}
