{
  description = "Home Services";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
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
    , hw-gauge
    , ...
    }@attrs:
    let
      inherit (nixpkgs.lib)
        mapAttrs mapAttrs' mapAttrsToList mkMerge nixosSystem splitString;

      inherit (flake-utils.lib) eachSystemMap system;

      # catalog.nodes defines the systems available in this flake.
      catalog = import ./catalog { inherit system; };

      authorizedKeys = splitString "\n" (builtins.readFile ../authorized_keys.txt);

      # Creates a nixosSystem attribute set for the specified node, allowing
      # the node config to be overridden.
      mkSystem =
        { hostName
        , node
        , sys ? node.system
        , hardware ? node.hw
        , environment ? "test"
        }:
        nixosSystem {
          system = sys;
          # `specialArgs` allows access to catalog, environment, etc with
          # hosts and roles.  `self` lets a host reference aspects of
          # itself.
          specialArgs = attrs // {
            inherit authorizedKeys catalog environment hostName;
            self = node;
          };
          modules = [
            node.config
            hardware
            agenix.nixosModule
            hw-gauge.nixosModules.default
          ];
        };
    in
    rec {
      # Convert nodes into a set of nixos configs.
      nixosConfigurations =
        let
          # Bare metal systems; in production environment.
          metalSystems = mapAttrs
            (hostName: node:
              mkSystem { inherit hostName node; environment = "prod"; })
            catalog.nodes;

          # Hyper-V systems, name prefixed with "hyper-"; in test environment.
          hypervSystems = mapAttrs'
            (hostName: node: {
              name = "hyper-${hostName}";
              value = mkSystem {
                inherit hostName node;
                hardware = ./hw/hyperv.nix;
              };
            })
            catalog.nodes;

          # libvirtd systems, name prefixed with "virt-"; in test environment.
          libvirtSystems = mapAttrs'
            (hostName: node: {
              name = "virt-${hostName}";
              value = mkSystem {
                inherit hostName node;
                hardware = ./hw/qemu.nix;
              };
            })
            catalog.nodes;
        in
        metalSystems // hypervSystems // libvirtSystems;

      # Generate an SD card image for each host.
      images = mapAttrs
        (host: node: nixosConfigurations.${host}.config.system.build.sdImage)
        catalog.nodes;

      # Generate VM build packages to quick test each host.  Note that these
      # will will be x86-64 VMs, and will have a new host key, thus will be
      # unable to decrypt agenix secrets.
      packages =
        let
          # Converts node entry into a virtual machine package.
          vmPackage = sys: hostName: node: {
            name = hostName;
            value = (mkSystem {
              inherit hostName node sys;
              hardware = ./hw/qemu.nix;
            }).config.system.build.vm;
          };

        in
        eachSystemMap [ system.x86_64-linux ]
          (sys: mapAttrs' (vmPackage sys) catalog.nodes);

      # Terraform commands.
      apps =
        eachSystemMap [ system.x86_64-linux ]
          (sys:
            let
              pkgs = nixpkgs.legacyPackages.${sys};
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
