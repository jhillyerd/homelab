{ inputs, ... }:

let
  inherit (inputs.flake-utils.lib) system;

  catalog = import ../nixos/catalog { inherit system; };
  confgen = import ../nixos/confgen inputs catalog;
in
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages = {
        confgen = confgen system;
      } // import ../pkgs { inherit pkgs; };
    };
}
