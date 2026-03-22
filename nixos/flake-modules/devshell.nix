{ inputs, ... }:

{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      octodns-cloudflare = pkgs.python3Packages.callPackage ../../pkgs/octodns-cloudflare.nix { };
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs =
          (with pkgs; [
            ansible
            cfssl
            consul
            kubectl
            nomad_1_10
            octodns
            octodns-providers.bind
            openssl
            sshpass
          ])
          ++ [
            inputs.agenix.packages.${system}.default
            octodns-cloudflare
          ];
      };
    };
}
