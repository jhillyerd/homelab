{
  description = "my nixos & ansible configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, agenix }:
    flake-utils.lib.eachDefaultSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        unstable = nixpkgs-unstable.legacyPackages.${system};
      in
        {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              agenix.defaultPackage.${system}
              ansible_2_9
              cfssl
              consul
              esphome
              nomad
              openssl
              platformio
              unstable.waypoint
            ];
          };
        }
      );
}
