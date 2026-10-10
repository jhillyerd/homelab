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
      url = "github:NousResearch/hermes-agent/v0.21.6";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pinned to the experimental channel on purpose: the newest stable tag
    # (v0.52.113, July 2026 code) predates hermes-agent's Sep 2026 module
    # decomposition and imports names v0.21.6 removed — degrading silently
    # (MCP tools, approval session keys). Only exp tags >= ~0.52.316 ship the
    # agent_compat shim. Re-pin together with the hermes-agent tag: the webui
    # is only tested against the agent release current at its release time.
    hermes-webui = {
      url = "github:nesquena/hermes-webui/exp-v0.52.458";
      inputs.nixpkgs.follows = "nixpkgs";
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
