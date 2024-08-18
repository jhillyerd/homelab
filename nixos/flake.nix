{
  description = "Home Services";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    nixd-flake.url = "github:nix-community/nixd/2.3.2";
    nixd-flake.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
    };

    agenix.url = "github:ryantm/agenix/0.15.0";
    agenix.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    homesite.url = "github:jhillyerd/homesite/main";
    homesite.inputs = {
      flake-utils.follows = "flake-utils";
      nixpkgs.follows = "nixpkgs";
    };

    hw-gauge.url = "github:jhillyerd/hw-gauge";
    hw-gauge.inputs = {
      flake-utils.follows = "flake-utils";
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, flake-utils, ... }@inputs:
    let
      inherit (nixpkgs.lib) mapAttrs;
      inherit (flake-utils.lib) eachSystemMap system;

      # catalog.nodes defines the systems available in this flake.
      catalog = import ./catalog { inherit system; };
    in
    rec {
      # Convert catalog.nodes into a set of NixOS configs.
      nixosConfigurations = import ./nix/nixos-configurations.nix inputs catalog;

      # Generate an SD card image for each node in the catalog.
      images = mapAttrs
        (host: node: nixosConfigurations.${host}.config.system.build.sdImage)
        catalog.nodes;

      # Configuration generators.
      packages =
        let
          confgen = import ./confgen inputs catalog;
        in
        eachSystemMap [ system.x86_64-linux ] (system:
          {
            confgen = confgen system;
          });
    };
}
