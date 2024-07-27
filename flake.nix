{
  description = "my nixos & ansible configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    agenix.url = "github:ryantm/agenix/0.13.0";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, nixpkgs-unstable, flake-utils, agenix, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          unstable = nixpkgs-unstable.legacyPackages.${system};
        in
        {
          devShell = pkgs.mkShell {
            buildInputs = (with pkgs; [
              ansible
              cfssl
              consul
              esphome
              kubectl
              nomad_1_6
              openssl
              platformio
              rnix-lsp
              sshpass
            ]) ++ [
              agenix.defaultPackage.${system}
              unstable.octodns
              unstable.octodns-providers.bind
            ];
          };
        }
      );
}
