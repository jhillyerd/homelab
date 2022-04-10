{
  description = "Home Services";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11"; };

  outputs = { self, nixpkgs }@attrs:
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
            modules = [ (./hosts + "/${host}.nix") node.hw ];
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
            modules = [ (./hosts + "/${host}.nix") ./hw/hyperv.nix ];
          };
        }) nodes;
      in metalSystems // hypervSystems;

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
            modules = [ (./hosts + "/${host}.nix") ./hw/qemu.nix ];
          }).config.system.build.vm;
        };
      }) nodes;
    };
}
