{ lib, nixpkgs }:
let
  allPkgs = nixpkgs // pkgs;
  callPackage = lib.callPackageWith allPkgs;
  pkgs = with nixpkgs; {
    website = callPackage ./website {};
    open-sans-webfont = callPackage ./open-sans-webfont {};
  };
in pkgs
