{
  description = "my nixos & ansible configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    agenix.url = "github:ryantm/agenix/0.15.0";
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
          devShell =
            let
              octodns-cloudflare = pkgs.python3Packages.callPackage ./pkgs/octodns-cloudflare.nix { };
            in
            pkgs.mkShell {
              buildInputs = (with pkgs; [
                ansible
                cfssl
                consul
                esphome
                kubectl
                nomad_1_7
                octodns
                octodns-providers.bind
                openssl
                platformio
                sshpass
              ]) ++ [
                agenix.packages.${system}.default
                octodns-cloudflare
              ];
            };
        }
      );
}
