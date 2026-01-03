{
  config,
  lib,
  pkgs,
  authorizedKeys,
  nixpkgs-unstable,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.roles.workstation;
in
{
  options.roles.workstation = {
    enable = mkEnableOption "Base CLI workstation";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      let
        system = pkgs.stdenv.hostPlatform.system;
        unstable = nixpkgs-unstable.legacyPackages.${system};
      in
      (with pkgs; [
        bashmount
        cachix
        chezmoi
        docker-compose
        fzf
        gcc
        gh
        gnumake
        kitty # always install for terminfo
        lazydocker
        lazygit
        lua51Packages.luarocks-nix # for rest.nvim
        lynx
        mqttui
        nfs-utils
        nixd
        nixfmt-rfc-style
        nixpkgs-review
        nodejs
        openssl
        patchelf
        postgresql_16
        python3Packages.python-lsp-server
        ripgrep
        sshfs
        starship
        steam-run-free
        lua-language-server
        tmux
        universal-ctags
        unzip
        usbutils
        watchexec
        yaml-language-server
        yazi # file manager
        zip
      ])
      ++ [
        unstable.devenv
      ];

    # Programs and services
    programs.direnv.enable = true;
    programs.fish.enable = true;
    programs.mosh.enable = true;
    programs.nix-ld.enable = true; # For non-nix binaries.

    # NFS mount support
    boot.supportedFilesystems = [ "nfs" ];
    services.rpcbind.enable = true;

    services.udisks2.enable = true;

    services.udev.extraRules = ''
      ACTION!="add|change", GOTO="probe_rs_rules_end"
      SUBSYSTEM=="gpio", MODE="0660", GROUP="dialout", TAG+="uaccess"
      SUBSYSTEM!="usb|tty|hidraw", GOTO="probe_rs_rules_end"

      # STMicroelectronics ST-LINK/V2
      ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="660", GROUP="dialout", TAG+="uaccess"
      # DAP42 Bluepill CMSIS-DAP Debug Probe
      ATTRS{idVendor}=="1209", ATTRS{idProduct}=="da42", MODE="660", GROUP="dialout", TAG+="uaccess"
      # Microbit v2 CMSIS-DAP Debug Probe
      ATTRS{idVendor}=="0d28", ATTRS{idProduct}=="0204", MODE="660", GROUP="dialout", TAG+="uaccess"
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
        "podman"
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
        trusted-users = [
          "root"
          "james"
        ];
      };

      # Enable nix flakes, not yet stable.
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
  };
}
