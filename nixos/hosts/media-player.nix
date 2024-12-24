{ config, self, util, ... }:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  networking.firewall.enable = false;
  services.resolved.enable = true;

  systemd.network.networks = util.mkWifiNetworks self;

  networking.wireless = {
    enable = true;
    secretsFile = config.age.secrets.wifi-env.path;
    networks.SKYNET.pskRaw = "ext:SKYNET_PSK";
  };
}
