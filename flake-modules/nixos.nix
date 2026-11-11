{ inputs, ... }:

let
  inherit (inputs.flake-utils.lib) system;

  catalog = import ../nixos/catalog { inherit system; };
in
{
  flake.nixosConfigurations = import ../nixos/nix/nixos-configurations.nix inputs catalog;
}
