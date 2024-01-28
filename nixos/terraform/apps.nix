{ nixpkgs, terranix, ... }@inputs: catalog: system:
let
  pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

  terraform = pkgs.terraform;

  cmd = {
    bat = "${pkgs.bat}/bin/bat";
    tf = "${pkgs.terraform}/bin/terraform";
  };

  terraformConfiguration = terranix.lib.terranixConfiguration {
    inherit system;
    modules = [ ./common.nix ./dns.nix ];
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
      ${cmd.bat} ${terraformConfiguration}
    '');
  };

  # nix run ".#tfplan"
  tfplan = {
    type = "app";
    program = toString (pkgs.writers.writeBash "plan" ''
      ${programInit}
      ${cmd.tf} init && ${cmd.tf} plan
    '');
  };

  # nix run ".#tfapply"
  tfapply = {
    type = "app";
    program = toString (pkgs.writers.writeBash "apply" ''
      ${programInit}
      ${cmd.tf} init && ${cmd.tf} apply
    '');
  };

  # nix run ".#tfdestroy"
  tfdestroy = {
    type = "app";
    program = toString (pkgs.writers.writeBash "destroy" ''
      ${programInit}
      ${cmd.tf} init && ${cmd.tf} destroy
    '');
  };
}
