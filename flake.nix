{
  description = "my nixos & ansible configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    agenix.url = "github:ryantm/agenix/0.13.0";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
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
              ansible
              cfssl
              consul
              esphome
              nomad
              unstable.octodns
              unstable.octodns-providers.bind
              openssl
              platformio
              rnix-lsp
              sshpass
            ];
          };
        }
      );
}
