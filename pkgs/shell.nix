# bootstrap nixpkgs for nix-shell
{ pkgsPath ? <nixpkgs> }:
import pkgsPath {
  overlays = [ (import ./overlay.nix) ];
}
