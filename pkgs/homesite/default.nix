{ pkgs, mkYarnPackage, utillinux }:
mkYarnPackage {
  name = "homesite";

  src = pkgs.fetchFromGitHub {
    owner = "jhillyerd";
    repo = "homesite";
    rev = "28f8e977b8514632304fe2347a06ff18045cdbc4";
    sha256 = "0q1jcfb7y6h4qg5qr4vaa9m1f2b1z26mdpv2f0ldx0g4qgl0jbhb";
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
