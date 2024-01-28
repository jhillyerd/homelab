# Builds nixosConfigurations flake output.
{ nixpkgs, agenix, hw-gauge, ... }@inputs: catalog:
let
  inherit (nixpkgs.lib)
    mapAttrs mapAttrs' mapAttrsToList mkMerge nixosSystem splitString;

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
        hardware
        node.config
        agenix.nixosModule
      ];
    };

  # Bare metal systems; in production environment.
  metalSystems = mapAttrs
    (hostName: node:
      mkSystem {
        inherit hostName node;
        modules = [ hw-gauge.nixosModules.default ];
        environment = "prod";
      })
    catalog.nodes;

  # Hyper-V systems, name prefixed with "hyper-"; in test environment.
  hypervSystems = mapAttrs'
    (hostName: node: {
      name = "hyper-${hostName}";
      value = mkSystem {
        inherit hostName node;
        hardware = ../hw/hyperv.nix;
      };
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
metalSystems // hypervSystems // libvirtSystems
