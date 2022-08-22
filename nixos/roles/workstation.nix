{ config, lib, pkgs, nixpkgs-unstable, ... }:
with lib;
let cfg = config.roles.workstation;
in
{
  options.roles.workstation = {
    enable = mkEnableOption "Base CLI workstation";

    graphical = mkEnableOption "Install Xorg and friends";
  };

  config = mkMerge [
    # Base workstation configuration.
    (mkIf cfg.enable {
      environment.systemPackages = with pkgs;
        let
          inherit (nixpkgs-unstable.legacyPackages.${system}) rnix-lsp rust-analyzer;

          x-www-browser = pkgs.writeShellScriptBin "x-www-browser" ''
            exec ${pkgs.google-chrome}/bin/google-chrome-stable "$@"
          '';
        in
        [
          bat
          chezmoi
          exa
          fzf
          gitAndTools.gh
          gitAndTools.git-absorb
          gitAndTools.gitflow
          gcc
          gnumake
          lazygit
          lynx
          nixpkgs-fmt
          nodejs
          patchelf
          postgresql_14
          python3
          ripgrep
          rnix-lsp
          rust-analyzer
          starship
          tmux
          universal-ctags
          unzip
          usbutils
          weechat
          zip
        ];

      # Programs and Services
      programs.fish.enable = true;

      # Setup ST-Link MCU probe.
      services.udev.extraRules = ''
        ACTION!="add|change", GOTO="probe_rs_rules_end"
        SUBSYSTEM=="gpio", MODE="0660", GROUP="dialout", TAG+="uaccess"
        SUBSYSTEM!="usb|tty|hidraw", GOTO="probe_rs_rules_end"
        # STMicroelectronics ST-LINK/V2
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="660", GROUP="dialout", TAG+="uaccess"
        LABEL="probe_rs_rules_end"
      '';

      virtualisation.docker.enable = true;

      # Environment
      environment.sessionVariables = {
        # Workaround for fish: https://github.com/NixOS/nixpkgs/issues/36146
        TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
      };

      # Users
      users.mutableUsers = true;

      # Extend common.nix user configuration
      users.users.james = {
        extraGroups = [
          "audio"
          "dialout"
          "docker"
          "libvirtd"
          "networkmanager"
          "vboxsf"
          "video"
          "wheel"
        ];
        shell = pkgs.fish;
        initialPassword = "hello github";
      };

      security.sudo.wheelNeedsPassword = false;
    })

    # Graphical workstation configuration.
    (mkIf (cfg.enable && cfg.graphical) {
      environment.systemPackages = with pkgs;
        let
          x-www-browser = pkgs.writeShellScriptBin "x-www-browser" ''
            exec ${pkgs.google-chrome}/bin/google-chrome-stable "$@"
          '';
          noxorg = [ rxvt_unicode.terminfo ];
        in
        [
          dfilemanager
          dmenu
          firefox
          gnome3.gedit
          google-chrome
          imwheel
          kitty
          lxappearance
          maim
          pantheon.elementary-icon-theme
          polybarFull
          pavucontrol
          rofi
          rxvt_unicode-with-plugins
          sxhkd
          virt-manager
          xclip
          x-www-browser
          xorg.xdpyinfo
          xorg.xev
          xsecurelock
          xss-lock
        ];

      programs.dconf.enable = true;

      services.xserver = {
        enable = true;
        layout = "us";
        windowManager.i3.enable = true;
        windowManager.awesome.enable = true;
      };

      fonts.fonts = with pkgs; [
        fira-code
        inconsolata
        noto-fonts
        siji
        terminus_font
        unifont
      ];

      # Enable sound.
      sound.enable = true;
      hardware.pulseaudio.enable = true;
    })
  ];
}
