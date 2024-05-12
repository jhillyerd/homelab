# Builds nixosConfigurations flake output.
{ nixpkgs, agenix, hw-gauge, ... }@inputs: catalog:
let
  inherit (nixpkgs.lib)
    mapAttrs mapAttrs' nixosSystem splitString;

  authorizedKeys = splitString "\n" (builtins.readFile ../../authorized_keys.txt);

  util = import ./util.nix { lib = nixpkgs.lib; };

  # Creates a nixosSystem attribute set for the specified node, allowing
  # the node config to be overridden.
  mkSystem =
    { hostName
    , node
    , hardware ? node.hw
    , modules ? [ ]
    , environment ? "test"
    }:
    nixosSystem {
      system = node.system;

      # `specialArgs` allows access to catalog, environment, etc with
      # hosts and roles.  `self` lets a host reference aspects of
      # itself.
      specialArgs = inputs // {
        inherit authorizedKeys catalog environment hostName util;
        self = node;
      };

      modules = modules ++ [
        (nodeModule node)
        hardware
        node.config
        agenix.nixosModule
        hw-gauge.nixosModules.default
      ];
    };

  # Common system config built from node entry.
  nodeModule = node: { hostName, ... }: {
    networking = {
      inherit hostName;
      hostId = node.hostId or null;
    };
  };

  # Bare metal systems; in production environment.
  metalSystems = mapAttrs
    (hostName: node:
      mkSystem {
        inherit hostName node;
        environment = "prod";
      })
    catalog.nodes;

  # libvirtd systems, name prefixed with "virt-"; in test environment.
  libvirtSystems = mapAttrs'
    (hostName: node: {
      name = "virt-${hostName}";
      value = mkSystem {
        inherit hostName node;
        hardware = ../hw/qemu.nix;
      };
    })
    catalog.nodes;
in
metalSystems // libvirtSystems
