{ pkgs }:
with pkgs;
substituteAllFiles {
  name = "home-website";

  src = ./src;

  files = [ "index.html" ];
}
