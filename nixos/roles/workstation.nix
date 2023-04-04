{ config, lib, pkgs, authorizedKeys, nixpkgs-unstable, devenv, ... }:
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
          bashmount
          bat
          cachix
          chezmoi
          devenv.packages.${system}.devenv
          direnv
          exa
          fzf
          gitAndTools.gh
          gitAndTools.git-absorb
          gcc
          gnumake
          lazygit
          lf
          lynx
          nfs-utils
          nix-direnv
          nixpkgs-fmt
          nodejs
          patchelf
          postgresql_14
          python3
          ripgrep
          rnix-lsp
          rust-analyzer
          starship
          sumneko-lua-language-server
          tmux
          universal-ctags
          unzip
          usbutils
          zip
        ];

      environment.pathsToLink = [ "/share/nix-direnv" ];

      # Programs and services
      programs.fish.enable = true;

      services.hw-gauge-daemon.enable = true;

      # NFS mount support
      boot.supportedFilesystems = [ "nfs" ];
      services.rpcbind.enable = true;

      services.udisks2.enable = true;

      # Setup ST-Link MCU probe.
      services.udev.extraRules = ''
        ACTION!="add|change", GOTO="probe_rs_rules_end"
        SUBSYSTEM=="gpio", MODE="0660", GROUP="dialout", TAG+="uaccess"
        SUBSYSTEM!="usb|tty|hidraw", GOTO="probe_rs_rules_end"

        # STMicroelectronics ST-LINK/V2
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="660", GROUP="dialout", TAG+="uaccess"
        # DAP42 Bluepill CMSIS-DAP Debug Probe
        ATTRS{idVendor}=="1209", ATTRS{idProduct}=="da42", MODE="660", GROUP="dialout", TAG+="uaccess"
        # WeACT Blackbill CMSIS-DAP Debug Probe
        ATTRS{idVendor}=="c251", ATTRS{idProduct}=="f001", MODE="660", GROUP="dialout", TAG+="uaccess"

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
        uid = 1026;
        isNormalUser = true;
        home = "/home/james";
        description = "James Hillyerd";
        shell = pkgs.fish;
        initialPassword = "hello github";

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

        openssh.authorizedKeys.keys = authorizedKeys;
      };

      services.autofs = {
        enable = true;
        debug = true;
        autoMaster =
          let
            netConf = pkgs.writeText "auto" ''
              skynas -rw,fstype=nfs4 /home skynas.home.arpa:/volume1/homes
            '';
          in
          ''
            /net file:${netConf}
          '';
      };

      security.sudo.wheelNeedsPassword = false;

      nix = {
        settings = {
          connect-timeout = 5;
          keep-derivations = true;
          keep-outputs = true;
          log-lines = 25;
          trusted-users = [ "root" "james" ];
          substituters = [ "https://devenv.cachix.org" ];
        };

        # Enable nix flakes, not yet stable.
        package = pkgs.nixFlakes;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };

      nixpkgs.overlays = [
        # Enable nix-direnv support for flakes, from:
        #  https://github.com/nix-community/nix-direnv
        (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; })
      ];
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
          dmenu
          firefox
          gimp
          gnome3.gedit
          google-chrome
          kitty
          lxappearance
          maim # takes screenshots
          pantheon.elementary-icon-theme
          polybarFull
          pavucontrol
          rofi
          rxvt_unicode-with-plugins
          sxhkd
          virt-manager
          x-www-browser
          xclip
          xfce.ristretto # image viwer
          xfce.thunar # file manager
          xfce.thunar-volman
          xfce.tumbler # thumbnails
          xorg.xdpyinfo
          xorg.xev
          xsecurelock
          xss-lock
        ];

      programs.dconf.enable = true;

      services.xserver = {
        enable = true;
        layout = "us";

        libinput.enable = true;
        libinput.mouse.accelProfile = "flat";

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
