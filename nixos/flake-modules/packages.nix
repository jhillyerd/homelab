{ inputs, ... }:

let
  inherit (inputs.flake-utils.lib) system;
  catalog = import ../catalog { inherit system; };
  confgen = import ../confgen inputs catalog;
in
{
  perSystem =
    { system, ... }:
    {
      packages.confgen = confgen system;
    };
}
