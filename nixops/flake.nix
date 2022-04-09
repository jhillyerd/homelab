{
  description = "Home Services";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11"; };

  outputs = { self, nixpkgs }@attrs:
    let
      inherit (nixpkgs.lib) mapAttrs mapAttrs' nixosSystem;

      catalog = import ./catalog.nix;

      # List of hosts available to build.
      nodes = { nexus = { hw = ./hw/cubi.nix; }; };

      # Build prod node set.
      prodNodes = mapAttrs (host: node:
        node // {
          hostName = host;
          config = ./hosts + "/${host}.nix";
          env = "prod";
        }) nodes;

      # Build test node set for virtual hardware.
      testNodes = mapAttrs' (host: node: {
        name = "test-${host}";
        value = node // {
          hostName = host;
          config = ./hosts + "/${host}.nix";
          hw = ./hw/qemu.nix;
          env = "test";
        };
      }) nodes;
    in rec {
      # Convert prod & test hosts into a set of output attrs.
      nixosConfigurations = mapAttrs' (host: node: {
        name = host;
        value = nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs // {
            inherit catalog;
            nodes = nixosConfigurations;
            hostName = node.hostName;
            environment = node.env;
          };
          modules = [ node.hw node.config ];
        };
      }) (prodNodes // testNodes);

      # Generate VM build packages to test each host.
      packages."x86_64-linux" = mapAttrs' (host: sys: {
        name = "${host}";
        value = sys.config.system.build.vm;
      }) self.nixosConfigurations;
    };
}
