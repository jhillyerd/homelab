# Builds nixosConfigurations flake output.
{
  nixpkgs,
  nixpkgs-unstable,
  agenix,
  agenix-template,
  hw-gauge,
  ...
}@inputs:
catalog:
let
  inherit (nixpkgs.lib) mapAttrs nixosSystem splitString;

  authorizedKeys = splitString "\n" (builtins.readFile ../../authorized_keys.txt);

  util = import ./util.nix {
    lib = nixpkgs.lib;
    inherit catalog;
  };

  # Creates a nixosSystem attribute set for the specified node, allowing
  # the node config to be overridden.
  mkSystem =
    {
      hostName,
      node,
      hardware ? node.hw,
      modules ? [ ],
    }:
    nixosSystem {
      system = node.system;

      # `specialArgs` allows access to catalog, etc with hosts and roles. `self`
      # lets a host reference aspects of itself.
      specialArgs = inputs // {
        inherit
          authorizedKeys
          catalog
          hostName
          util
          ;
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${node.system};
        self = node;
      };

      modules = modules ++ [
        (nodeModule node)
        hardware
        node.config
        agenix.nixosModules.default
        agenix-template.nixosModules.default
        hw-gauge.nixosModules.default
      ];
    };

  # Common system config built from node entry.
  nodeModule =
    node:
    { hostName, ... }:
    {
      networking = {
        inherit hostName;
        domain = "home.arpa";
        hostId = node.hostId or null;
      };
    };
in
mapAttrs (
  hostName: node:
  mkSystem {
    inherit hostName node;
  }
) catalog.nodes
