{
  description = "Home Services";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11"; };

  outputs = { self, nixpkgs }@attrs:
    let
      inherit (nixpkgs.lib) mapAttrs mapAttrs' nixosSystem;

      catalog = import ./catalog.nix;

      # Set of hosts available to build.
      nodes = { nexus = { hw = ./hw/cubi.nix; }; };
    in rec {
      # Convert nodes into a set of nixos configs.
      nixosConfigurations = mapAttrs' (host: node: {
        name = host;
        value = nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs // {
            inherit catalog;
            hostName = host;
            environment = "prod";
          };
          modules = [(./hosts + "/${host}.nix") node.hw  ];
        };
      }) nodes;

      # Generate VM build packages to test each host.
      packages."x86_64-linux" = mapAttrs' (host: sys: {
        name = "${host}";
        value = (nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs // {
            inherit catalog;
            hostName = host;
            environment = "test";
          };
          modules = [(./hosts + "/${host}.nix") ./hw/qemu.nix ];
        }).config.system.build.vm;
      }) nodes;
    };
}
