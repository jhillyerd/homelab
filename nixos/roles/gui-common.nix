{
  config,
  pkgs,
  lib,
  hermes-desktop,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.roles.gui-common;

  # Remote-only Hermes desktop shell: the bundled local agent runtime is
  # replaced by a stub. GUI machines talk to the gateway on the `hermes`
  # host; saved remote connections live in ~/.hermes.
  hermesDesktop =
    let
      hermesStub = pkgs.runCommand "hermes-remote-stub" { meta.mainProgram = "hermes"; } ''
        mkdir -p $out/bin
        printf '%s\n' \
          '#!/bin/sh' \
          'echo "hermes-desktop: remote-only build - connect to the hermes gateway instead" >&2' \
          'exit 127' > $out/bin/hermes
        chmod +x $out/bin/hermes
      '';
    in
    hermes-desktop.packages.${pkgs.stdenv.hostPlatform.system}.minimal.hermesDesktop.override {
      hermesAgent = hermesStub;
    };
in
{
  options.roles.gui-common = {
    enable = mkEnableOption "Common to all GUI roles";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        alsa-utils
        appimage-run
        audacity
        firefox
        gimp
        libnotify # for notify-send
        obs-studio
        pavucontrol
        remmina
        ungoogled-chromium
        virt-manager
      ]
      ++ [ hermesDesktop ];

    programs.dconf.enable = true;

    programs._1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ "james" ];
    };

    services.greetd = {
      enable = true;
      useTextGreeter = true;

      settings = {
        default_session = {
          command = pkgs.writeShellScript "start-tuigreet" ''
            setterm --blank=10
            setterm --powersave on
            ${pkgs.tuigreet}/bin/tuigreet \
              --time --remember --remember-user-session
          '';
          user = "greeter";
        };
      };
    };

    # Allows startxfce4/startx to work.
    services.xserver.exportConfiguration = true;

    services.libinput.enable = true;
    services.libinput.mouse.accelProfile = "flat";

    services.syncthing = {
      enable = true;
      user = "james";
      dataDir = "/home/james";
    };
    users.users.james.extraGroups = [ "syncthing" ];

    fonts.packages = with pkgs; [
      font-awesome
      fira-code
      inconsolata
      noto-fonts
      terminus_font
    ];

    # Sound.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Bluetooth.
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    services.blueman.enable = true;

    # Printer support.
    services.printing = {
      enable = true;
      drivers = [ pkgs.canon-cups-ufr2 ];
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
