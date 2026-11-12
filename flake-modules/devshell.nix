{ inputs, ... }:

{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs =
          (with pkgs; [
            age
            ansible
            cfssl
            consul
            kubectl
            nomad_1_11
            octodns
            octodns-providers.bind
            openssl
            sshpass
            wireguard-tools
          ])
          ++ [
            inputs.agenix.packages.${system}.default
            inputs.self.packages.${system}.octodns-cloudflare
          ];
      };
    };
}
