{
  config,
  self,
  util,
  pkgs,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  # Kodi media player config.
  services.xserver.enable = true;
  services.xserver.displayManager = {
    lightdm.greeter.enable = false;
  };
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kodi";

  services.xserver.desktopManager.kodi = {
    enable = true;
    package = pkgs.kodi.withPackages (
      pkgs: with pkgs; [
        jellycon
      ]
    );
  };
  users.extraUsers.kodi.isNormalUser = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  networking.firewall.enable = false;
  services.resolved.enable = true;

  systemd.network.enable = true;
  systemd.network.networks = util.mkWifiNetworks self { Name = "wlp2s0"; };

  networking.wireless = {
    enable = true;
    secretsFile = config.age.secrets.wifi-env.path;
    networks.SKYNET.pskRaw = "ext:SKYNET_PSK";
  };
}
