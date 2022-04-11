{
  description = "Home Services";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, agenix }@attrs:
    let
      inherit (nixpkgs.lib) mapAttrs mapAttrs' nixosSystem;

      catalog = import ./catalog.nix;

      # Set of hosts available to build.
      nodes = {
        nexus = {
          system = "x86_64-linux";
          hw = ./hw/cubi.nix;
        };
      };
    in rec {
      # Convert nodes into a set of nixos configs.
      nixosConfigurations = let
        # Bare metal systems.
        metalSystems = mapAttrs (host: node:
          nixosSystem {
            inherit (node) system;
            specialArgs = attrs // {
              inherit catalog;
              hostName = host;
              environment = "prod";
            };
            modules = [ (./hosts + "/${host}.nix") node.hw agenix.nixosModule ];
          }) nodes;

        # Hyper-V systems, name prefixed with "hyper-"; in test environment.
        hypervSystems = mapAttrs' (host: node: {
          name = "hyper-${host}";
          value = nixosSystem {
            inherit (node) system;
            specialArgs = attrs // {
              inherit catalog;
              hostName = host;
              environment = "test";
            };
            modules =
              [ (./hosts + "/${host}.nix") ./hw/hyperv.nix agenix.nixosModule ];
          };
        }) nodes;

        # libvirtd systems, name prefixed with "virt-"; in test environment.
        libvirtSystems = mapAttrs' (host: node: {
          name = "virt-${host}";
          value = nixosSystem {
            inherit (node) system;
            specialArgs = attrs // {
              inherit catalog;
              hostName = host;
              environment = "test";
            };
            modules =
              [ (./hosts + "/${host}.nix") ./hw/qemu.nix agenix.nixosModule ];
          };
        }) nodes;
      in metalSystems // hypervSystems // libvirtSystems;

      # Generate VM build packages to test each host.
      packages = mapAttrs' (host: node: {
        name = node.system;
        value = {
          ${host} = (nixosSystem {
            inherit (node) system;
            specialArgs = attrs // {
              inherit catalog;
              hostName = host;
              environment = "test";
            };
            modules =
              [ (./hosts + "/${host}.nix") ./hw/qemu.nix agenix.nixosModule ];
          }).config.system.build.vm;
        };
      }) nodes;
    };
}
