{
  description = "my nixops & ansible configruation";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    hello.url = "github:ihsanturk/hello-world-nix?rev=03ec3abd2def85a97425660a96aa31565cc77821"; 
  };

  outputs = { self, nixpkgs, flake-utils, hello }:
    flake-utils.lib.eachDefaultSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              ansible
              hello.defaultPackage.${system}
            ];
          };
        }
      );
}
