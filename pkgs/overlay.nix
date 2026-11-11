# Overlay exposing this repo's packages (see default.nix) to host configurations.
final: prev: import ./default.nix { pkgs = final; }
