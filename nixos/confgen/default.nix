{ nixpkgs, ... }:
catalog: system:
let
  pkgs = nixpkgs.legacyPackages.${system};

  octodnsBundle = import ./octodns { inherit pkgs catalog; };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "config-outputs";

  nativeBuildInputs = [
    pkgs.jq
    pkgs.remarshal
  ];

  dontUnpack = true;

  # Write the entire config bundle as a single JSON file.
  jsonBundle = (builtins.toJSON octodnsBundle);
  passAsFile = [ "jsonBundle" ];

  installPhase = ''
    mkdir $out
    cd $out

    # Loop over each destination file name from the JSON bundle.
    jq -r "keys | .[]" $jsonBundlePath | while read fpath; do
      if [[ -z "$fpath" ]]; then
        echo "Empty destination file path for config!" >&2
        exit 1
      fi

      # Create destination directory and convert syntax.
      mkdir -p $(dirname "$fpath")
      if [[ "$fpath" == *.yaml ]]; then
        jq ".[\"$fpath\"]" $jsonBundlePath | json2yaml > "$fpath"
      else
        jq ".[\"$fpath\"]" $jsonBundlePath > "$fpath"
      fi
    done
  '';
}
