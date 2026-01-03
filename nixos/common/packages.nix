{ pkgs, nixpkgs-unstable, ... }:
{
  environment.systemPackages =
    let
      system = pkgs.stdenv.hostPlatform.system;
      unstable = nixpkgs-unstable.legacyPackages.${system};

      remaps = [
        (pkgs.writeShellScriptBin "vim" ''
          exec /run/current-system/sw/bin/nvim "$@"
        '')
      ];
    in
    (with pkgs; [
      bat
      bind
      file
      git
      htop
      jq
      lf
      lsof
      mailutils
      ncdu # ncurses disk usage
      nmap
      psmisc
      python3
      smartmontools
      tree
      wget
    ])
    ++ (with unstable; [ neovim ])
    ++ remaps;
}
