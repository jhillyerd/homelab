{ pkgsPath ? <nixpkgs> }:
(import pkgsPath {
  overlays = [ (import ../overlay.nix) ];
}).website
