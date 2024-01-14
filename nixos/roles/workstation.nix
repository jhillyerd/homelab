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
        in
        [
          bashmount
          bat
          cachix
          chezmoi
          devenv.packages.${system}.devenv
          fzf
          gitAndTools.gh
          gitAndTools.git-absorb
          gcc
          gnumake
          kitty # always install for terminfo
          lazygit
          lf
          lynx
          mqttui
          nfs-utils
          nixpkgs-fmt
          nixpkgs-review
          nodejs
          patchelf
          postgresql_14
          python3
          ripgrep
          rnix-lsp
          rust-analyzer
          sshfs
          starship
          sumneko-lua-language-server
          tmux
          universal-ctags
          unzip
          usbutils
          zip
        ];

      # Programs and services
      programs.direnv.enable = true;
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
    })

    # Graphical workstation configuration.
    (mkIf (cfg.enable && cfg.graphical) {
      environment.systemPackages = with pkgs;
        let
          x-www-browser = pkgs.writeShellScriptBin "x-www-browser" ''
            exec ${pkgs.firefox}/bin/firefox "$@"
          '';
        in
        [
          dmenu
          dunst
          firefox
          gimp
          gnome3.gedit
          google-chrome
          libnotify # for notify-send
          lxappearance
          maim # takes screenshots
          obs-studio
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

      fonts.packages = with pkgs; [
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

      # IPP Printer support.
      services.printing.enable = true;
      services.avahi = {
        enable = true;
        nssmdns = true;
        openFirewall = true;
      };
    })
  ];
}
