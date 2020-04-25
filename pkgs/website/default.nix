with import <nixpkgs> {};
substituteAllFiles {
  name = "home-website";

  src = ./src;

  files = [ "index.html" ];
}
