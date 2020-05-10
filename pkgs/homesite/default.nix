{ pkgs, mkYarnPackage, utillinux }:
mkYarnPackage {
  name = "homesite";

  src = pkgs.fetchFromGitHub {
    owner = "jhillyerd";
    repo = "homesite";
    rev = "ac0a33d7d2a8e3a71aef8148436a907f9ddb1662";
    sha256 = "02mfkq2j32h8xksdbpl79bri5z8wpnlfsixxki9kpy4j4zsi68ks";
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
