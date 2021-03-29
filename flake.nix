{
  description = "my nixops & ansible configruation";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    hello.url = "github:ihsanturk/hello-world-nix?rev=03ec3abd2def85a97425660a96aa31565cc77821"; 
    nixops-flake.url = "github:input-output-hk/nixops-flake";
  };

  outputs = { self, nixpkgs, flake-utils, hello, nixops-flake }:
    flake-utils.lib.eachDefaultSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              ansible
              esphome
              hello.defaultPackage.${system}
              nixops-flake.defaultPackage.${system}
            ];
          };
        }
      );
}
