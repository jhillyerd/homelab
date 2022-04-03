{
  description = "Build Raspberry Pi network";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";

    faasd = {
      url = "github:welteki/faasd-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, faasd }@attrs:
    # List of hosts we wish to build, each should have a corresponding .nix
    # file in the hosts directory.
    let
      inherit (nixpkgs.lib) attrsets;

      hosts = [ "faas" ];
    in rec {
      # Convert the list of hosts into a nixosConfigurations attribute set.
      nixosConfigurations = attrsets.genAttrs hosts (host:
        nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = attrs;
          modules = [
            ./sd-image-pi3.nix
            ./common.nix
            { networking.hostName = host; }
            (./hosts + "/${host}.nix")
          ];
        });

      # Define a flake image from each of the host nixosConfigurations.
      images = attrsets.genAttrs hosts
        (host: nixosConfigurations."${host}".config.system.build.sdImage);
    };
}
