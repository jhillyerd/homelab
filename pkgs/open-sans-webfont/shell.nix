{ pkgsPath ? <nixpkgs> }:
(import pkgsPath {
  overlays = [ (import ../overlay.nix) ];
}).open-sans-webfont
