{ ... }:
let
  dir = builtins.readDir ./.;
  nixFiles = builtins.filter (
    name: name != "default.nix" && builtins.match ".*\\.nix$" name != null
  ) (builtins.attrNames dir);
in
{
  # Import all .nix files in the current directory.
  imports = map (f: ./. + "/${f}") nixFiles;
}
