{ pkgs }:
with pkgs;
{
  website = callPackage ./website {};
  open-sans-webfont = callPackage ./open-sans-webfont {};
}
