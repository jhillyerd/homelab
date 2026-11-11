{ inputs, ... }:

let
  inherit (inputs.flake-utils.lib) system;

  catalog = import ../nixos/catalog { inherit system; };
in
{
  flake.nixosConfigurations = import ../nixos/lib/nixos-configurations.nix inputs catalog;
}
