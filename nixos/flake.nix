{
  description = "Home Services";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    agenix.url = "github:ryantm/agenix/0.13.0";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv/v0.6";

    homesite.url = "github:jhillyerd/homesite/main";
    homesite.inputs.flake-utils.follows = "flake-utils";
    homesite.inputs.nixpkgs.follows = "nixpkgs";

    hw-gauge.url = "github:jhillyerd/hw-gauge";
    hw-gauge.inputs.flake-utils.follows = "flake-utils";
    hw-gauge.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    terranix.url = "github:terranix/terranix";
    terranix.inputs.flake-utils.follows = "flake-utils";
    terranix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , flake-utils
    , agenix
    , terranix
    , ...
    }@inputs:
    let
      inherit (nixpkgs.lib)
        mapAttrs mapAttrs' mapAttrsToList mkMerge nixosSystem splitString;

      inherit (flake-utils.lib) eachSystemMap system;

      # catalog.nodes defines the systems available in this flake.
      catalog = import ./catalog { inherit system; };
    in
    rec {
      # Convert nodes into a set of nixos configs.
      nixosConfigurations = import ./nix/nixos-configurations.nix inputs catalog;

      # Generate an SD card image for each host.
      images = mapAttrs
        (host: node: nixosConfigurations.${host}.config.system.build.sdImage)
        catalog.nodes;

      # Terraform commands.
      apps =
        eachSystemMap [ system.x86_64-linux ]
          (sys:
            let
              pkgs = import nixpkgs { system = sys; config.allowUnfree = true; };
              terraform = pkgs.terraform;
              terraformConfiguration = terranix.lib.terranixConfiguration {
                system = sys;
                modules = [ ./terraform/common.nix ./terraform/dns.nix ];
                extraArgs = { inherit catalog; };
              };
              programInit = ''
                if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
                cp ${terraformConfiguration} config.tf.json
              '';
            in
            {
              # nix run ".#tfcat"
              tfcat = {
                type = "app";
                program = toString (pkgs.writers.writeBash "cat" ''
                  ${pkgs.bat}/bin/bat ${terraformConfiguration}
                '');
              };
              # nix run ".#tfplan"
              tfplan = {
                type = "app";
                program = toString (pkgs.writers.writeBash "plan" ''
                  ${programInit}
                  ${terraform}/bin/terraform init \
                    && ${terraform}/bin/terraform plan
                '');
              };
              # nix run ".#tfapply"
              tfapply = {
                type = "app";
                program = toString (pkgs.writers.writeBash "apply" ''
                  ${programInit}
                  ${terraform}/bin/terraform init \
                    && ${terraform}/bin/terraform apply
                '');
              };
              # nix run ".#tfdestroy"
              tfdestroy = {
                type = "app";
                program = toString (pkgs.writers.writeBash "destroy" ''
                  ${programInit}
                  ${terraform}/bin/terraform init \
                    && ${terraform}/bin/terraform destroy
                '');
              };
            });
    };
}
