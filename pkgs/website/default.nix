{ pkgs, stdenv, open-sans-webfont }:
stdenv.mkDerivation {
  name = "home-website";

  src = ./src;

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildPhase = ''
    for f in *.html; do
      echo "- substituting $f"
      substituteAllInPlace $f
    done
  '';

  installPhase = ''
    mkdir $out
    mv -v * $out/

    mkdir $out/fonts
    cp -v ${open-sans-webfont}/* $out/fonts
  '';
}
