{ pkgs, open-sans-webfont }:
let
  webfont = open-sans-webfont;
in with pkgs;
substituteAllFiles {
  name = "home-website";

  src = ./src;
  files = [ "index.html" ];

  inherit webfont;
}
