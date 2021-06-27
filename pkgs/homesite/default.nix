{ pkgs, mkYarnPackage, utillinux }:
mkYarnPackage {
  name = "homesite";

  src = pkgs.fetchFromGitHub {
    owner = "jhillyerd";
    repo = "homesite";
    rev = "62f2b4cbea09e181fb43c449a848f4b8d74f55fe";
    sha256 = "0057f043fszz6qpwympfxrjshgvm8d5yymynp52isxf53galz97j";
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
