{
  description = "Home Services";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11"; };

  outputs = { self, nixpkgs }@attrs:
    let
      inherit (nixpkgs.lib) attrsets nixosSystem;

      # List of hosts available to build.
      hosts = [ "nexus" ];
    in rec {
      # Convert list of hosts into a set of output attrs.
      nixosConfigurations = attrsets.genAttrs hosts (host:
        nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs // { nodes = nixosConfigurations; };
          modules =
            [ { networking.hostName = host; } (./hosts + "/${host}.nix") ];
        });

      # Generate VM build packages to test each host.
      packages."x86_64-linux" = with nixpkgs.lib;
        mapAttrs' (host: sys: {
          name = "vm-${host}";
          value = sys.config.system.build.vm;
        }) self.nixosConfigurations;
    };

}
