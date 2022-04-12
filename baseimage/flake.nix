{
  description = "VM deployment target base images";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators }:
    let
      inherit (nixpkgs) lib;
      baseModule = { ... }: {
        services.openssh = {
          enable = true;
          permitRootLogin = "yes";
        };

        time.timeZone = "US/Pacific";

        users.users.root.openssh.authorizedKeys.keys =
          lib.splitString "\n" (builtins.readFile ../authorized_keys.txt);
      };
    in {
      packages."x86_64-linux" = {
        hyperv = nixos-generators.nixosGenerate {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ baseModule ];
          format = "hyperv";
        };

        libvirt = nixos-generators.nixosGenerate {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ baseModule { services.qemuGuest.enable = true; } ];
          format = "qcow";
        };
      };
    };
}
