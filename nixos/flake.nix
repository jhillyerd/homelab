{
  description = "Home Services";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    agenix.url = "github:ryantm/agenix/0.13.0";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv/v0.6";

    homesite.url = "github:jhillyerd/homesite/main";
    homesite.inputs.flake-utils.follows = "flake-utils";
    homesite.inputs.nixpkgs.follows = "nixpkgs";

    hw-gauge.url = "github:jhillyerd/hw-gauge";
    hw-gauge.inputs.flake-utils.follows = "flake-utils";
    hw-gauge.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    terranix.url = "github:terranix/terranix";
    terranix.inputs.flake-utils.follows = "flake-utils";
    terranix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , flake-utils
    , agenix
    , ...
    }@inputs:
    let
      inherit (nixpkgs.lib)
        mapAttrs mapAttrs' mapAttrsToList mkMerge nixosSystem splitString;

      inherit (flake-utils.lib) eachSystemMap system;

      # catalog.nodes defines the systems available in this flake.
      catalog = import ./catalog { inherit system; };
    in
    rec {
      # Convert nodes into a set of nixos configs.
      nixosConfigurations = import ./nix/nixos-configurations.nix inputs catalog;

      # Generate an SD card image for each host.
      images = mapAttrs
        (host: node: nixosConfigurations.${host}.config.system.build.sdImage)
        catalog.nodes;

      # Terraform commands.
      apps =
        let
          tf-apps = import ./terraform/apps.nix inputs catalog;
        in
        eachSystemMap [ system.x86_64-linux ] tf-apps;
    };
}
