let
  pkgs = import <nixpkgs> {};

  pythonOverrides = self: super: {
    jedi = super.jedi.overridePythonAttrs (old: rec {
      version = "0.17.0";
      src = super.fetchPypi {
        pname = old.pname;
        sha256 = "0c1h9x3a9klvk2g288wl328x8xgzw7136k6vs9hkd56b85vcjh6z";
        inherit version;
      };
    });

    parso = super.parso.overridePythonAttrs (old: rec {
      version = "0.7.0";
      src = super.fetchPypi {
        pname = old.pname;
        sha256 = "0b7irps2dqmzq41sxbpvxbivhh1x2hwmbqp45bbpd82446p9z3lh";
        inherit version;
      };
    });
  };

  python = pkgs.python37.override {
    packageOverrides = pythonOverrides;
    self = python;
  };

  pythonEnv = python.withPackages (
    packages: with packages; [
      flake8
      jedi
    ]);
in with pkgs;
stdenv.mkDerivation rec {
  name = "env";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = [
    ansible
    ansible-lint
    kubectl
    pythonEnv
  ];
  shellHook = ''
    export KUBECONFIG="$(pwd)/rke/kube_config_cluster.yml"
  '';
}
