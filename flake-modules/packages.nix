{ inputs, ... }:

let
  inherit (inputs.flake-utils.lib) system;
  catalog = import ../nixos/catalog { inherit system; };
  confgen = import ../nixos/confgen inputs catalog;
in
{
  perSystem =
    { system, ... }:
    {
      packages.confgen = confgen system;
    };
}
