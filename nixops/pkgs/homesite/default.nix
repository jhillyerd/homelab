{ pkgs, mkYarnPackage, utillinux }:
mkYarnPackage {
  name = "homesite";

  src = pkgs.fetchFromGitHub {
    owner = "jhillyerd";
    repo = "homesite";
    rev = "f194efd29c5e1b0a43a92a53ce608f94a6d731c3";
    sha256 = "05156ibkgx4hsm3qwknpgz9x7mqrklgyvw0x16z3yknr8rssb0vs";
  };

  yarNix = ./yarn.nix;

  extraBuildInputs = [ utillinux ];

  phases = [ "unpackPhase" "configurePhase" "buildPhase" "installPhase" ];

  buildPhase = ''
    yarn run build
  '';

  installPhase = ''
    cd "deps/$pname/dist"
    echo ======
    pwd
    find . -name index.html
    echo ======
    mkdir $out
    cp -v * $out/
  '';
}
