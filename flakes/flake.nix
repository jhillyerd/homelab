{
  description = "Build Raspberry Pi 3 image";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs }:
    # List of hosts we wish to build, each should have a corresponding .nix
    # file in the hosts directory.
    let hosts = [ "mypi3" ];

    in with nixpkgs.lib; rec {
      # Convert the list of hosts into a nixosConfigurations attribute set.
      nixosConfigurations = attrsets.genAttrs hosts (host:
        nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
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
