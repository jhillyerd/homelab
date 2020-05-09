{ pkgs, stdenv, nodejs-12_x }:
stdenv.mkDerivation {
  name = "homesite";

  src = pkgs.fetchFromGitHub {
    owner = "jhillyerd";
    repo = "homesite";
    rev = "f0ded6ae77eed970374872c1a605b86b4cf7aca7";
    sha256 = "0dx1rng8sqinka87rgy6mwr4zr5a1v5scrb6b5j91h6x3vfdg38r";
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
