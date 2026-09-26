{
  description = "my nixos & ansible configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    agenix = {
      url = "github:ryantm/agenix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-template.url = "github:jhillyerd/agenix-template/main";

    hermes-agent = {
      url = "github:NousResearch/hermes-agent/v2026.9.24";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop client for the hermes-agent gateway. Deliberately does NOT
    # follow our nixpkgs: upstream's nix/desktop.nix hash-pins the Electron
    # headers tarball, which only matches the default electron in their own
    # locked nixpkgs. Keep both hermes inputs on the same tag.
    hermes-desktop = {
      url = "github:NousResearch/hermes-agent/v2026.9.24";
    };

    homesite = {
      url = "github:jhillyerd/homesite/main";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hw-gauge = {
      url = "github:jhillyerd/hw-gauge";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./flake-modules/nixos.nix
        ./flake-modules/packages.nix
        ./flake-modules/devshell.nix
      ];
    };
}
