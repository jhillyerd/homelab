{ pkgs, nixpkgs-unstable, ... }: {
  environment.systemPackages =
    let
      unstable = nixpkgs-unstable.legacyPackages.${pkgs.system};

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
      nmap
      psmisc
      python3
      smartmontools
      tree
      wget
    ]) ++ (with unstable; [
      neovim
    ]) ++ remaps;
}
