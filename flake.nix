{
  description = "home lab: nixos hosts, nomad jobs & ops tooling";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    agenix = {
      url = "github:ryantm/agenix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-template.url = "github:jhillyerd/agenix-template/main";

    hermes-agent = {
      url = "github:NousResearch/hermes-agent/v0.23.0";
      inputs.flake-parts.follows = "flake-parts";
      # Do NOT follow our nixpkgs: their pm-packages patch patchelf with an
      # upstream 0.19.x-line fix, which fails to apply against nixos-26.05's
      # patchelf 0.15.2 (stable downgraded it after the 0.19.2 corruption
      # bug). Build against their own CI-tested nixpkgs pin instead.
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

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      # Pinned to their own nixpkgs-unstable: packages are CI-tested against
      # it daily, and we have no numtide cache configured to make a local
      # rebuild against ours worthwhile.
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
