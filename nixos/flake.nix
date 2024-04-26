{
  description = "Home Services";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    nixd-flake.url = "github:nix-community/nixd";
    nixd-flake.inputs = {
      nixpkgs.follows = "nixpkgs-unstable";
    };

    agenix.url = "github:ryantm/agenix/0.13.0";
    agenix.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    devenv.url = "github:cachix/devenv/v0.6";

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

    terranix.url = "github:terranix/terranix";
    terranix.inputs = {
      flake-utils.follows = "flake-utils";
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, flake-utils, ... }@inputs:
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

      # Homelab commands.
      apps =
        let
          tf-apps = import ./terraform/apps.nix inputs catalog;
        in
        eachSystemMap [ system.x86_64-linux ] tf-apps;
    };
}
