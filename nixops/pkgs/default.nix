# Bootstrap the overlay.
{ pkgsPath ? <nixpkgs> }:
import pkgsPath {
  overlays = [ (import ./overlay.nix) ];
}
