{ pkgs, stdenv, nodejs-12_x }:
stdenv.mkDerivation {
  name = "homesite";

  src = pkgs.fetchFromGitHub {
    owner = "jhillyerd";
    repo = "homesite";
    rev = "7af300e05b5fa236342d9323d2813513eeececb9";
    sha256 = "0ylsx3gp1lq84d6h7zx0hmqag5xvgsxxl935nv6a9z6k666k7h2q";
  };

  buildInputs = [ nodejs-12_x ];

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildPhase = ''
    export HOME="$(mktemp -d)"
    npm ci
    npm run build
  '';

  installPhase = ''
    mkdir $out
    cd dist
    mv -v * $out/
  '';
}
