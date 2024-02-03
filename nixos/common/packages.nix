{ config, pkgs, lib, nixpkgs-unstable, ... }: {
  environment.systemPackages = with pkgs;
    let
      # Use unstable neovim.
      neovim = nixpkgs-unstable.legacyPackages.${system}.neovim;

      vim-is-neovim = pkgs.writeShellScriptBin "vim" ''
        exec ${neovim}/bin/nvim "$@"
      '';
    in
    [
      bat
      bind
      file
      git
      htop
      jq
      lf
      lsof
      mailutils
      neovim
      nmap
      psmisc
      tree
      vim-is-neovim
      wget
    ];
}
