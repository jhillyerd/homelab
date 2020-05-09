{ pkgs, stdenv, nodejs-12_x, nodePackages, utillinux }:
stdenv.mkDerivation {
  name = "homesite";

  src = pkgs.fetchFromGitHub {
    owner = "jhillyerd";
    repo = "homesite";
    rev = "373891da91bfd73275e25697477dfa31b8b39787";
    sha256 = "1zfvpf17nwcl9qm3sx9l4w2qy6dzrdv4jmp94fkva88k6s3xvz12";
  };

  buildInputs = [ nodejs-12_x nodePackages.node2nix utillinux ];

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
