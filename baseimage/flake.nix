{
  description = "VM deployment target base images";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators }:
    let
      inherit (nixpkgs) lib;

      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      baseModule = { ... }: {
        services.openssh = {
          enable = true;
          permitRootLogin = "yes";
        };

        time.timeZone = "US/Pacific";

        users.users.root.openssh.authorizedKeys.keys =
          lib.splitString "\n" (builtins.readFile ../authorized_keys.txt);

        # Display the IP address at the login prompt.
        environment.etc."issue.d/ip.issue".text = ''
          IPv4: \4
        '';
        networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";
      };
    in {
      packages.${system} = {
        hyperv = nixos-generators.nixosGenerate {
          inherit pkgs;
          modules = [ baseModule ];
          format = "hyperv";
        };

        libvirt = nixos-generators.nixosGenerate {
          inherit pkgs;
          modules = [ baseModule { services.qemuGuest.enable = true; } ];
          format = "qcow";
        };
      };
    };
}
