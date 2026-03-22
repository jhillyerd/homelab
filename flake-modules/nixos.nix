{ inputs, ... }:

let
  inherit (inputs.nixpkgs.lib) mapAttrs;
  inherit (inputs.flake-utils.lib) system;

  catalog = import ../nixos/catalog { inherit system; };
in
{
  flake = {
    nixosConfigurations = import ../nixos/nix/nixos-configurations.nix inputs catalog;

    images = mapAttrs (
      host: _: inputs.self.nixosConfigurations.${host}.config.system.build.sdImage
    ) catalog.nodes;
  };
}
