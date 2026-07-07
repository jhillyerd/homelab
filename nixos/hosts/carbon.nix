{
  pkgs,
  config,
  catalog,
  ...
}:
{
  imports = [ ../common.nix ];

  age.secrets.wifi-env.file = ../secrets/wifi-env.age;

  roles.gui-sway.enable = true;
  roles.workstation.enable = true;

  # NetworkManager for wifi.
  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
  };

  # systemd-network for everything else.
  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };

  services.resolved.enable = true;

  # SKYNET wifi with split-DNS for the home cluster, applied only while
  # associated with this network. Analogous to common/onprem.nix, but scoped to
  # the link so it disappears when roaming. `~home.arpa` is a routing-only
  # domain: matching lookups go to the cluster resolvers instead of falling
  # through to the fallback (1.1.1.1), which returns NXDOMAIN for the IANA
  # `home.arpa` zone.
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.age.secrets.wifi-env.path ];
    profiles.skynet = {
      connection = {
        id = "SKYNET";
        type = "wifi";
      };
      wifi = {
        ssid = "SKYNET";
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$SKYNET_PSK";
      };
      ipv4 = {
        method = "auto";
        dns = "${catalog.dns.ns2};${catalog.dns.ns3};${catalog.dns.ns1};";
        dns-search = "~home.arpa;~dyn.home.arpa;";
      };
      ipv6.method = "auto";
    };
  };

  # Backlight controls.
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
      }
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "${pkgs.brightnessctl}/bin/brightnessctl set 10%+";
      }
    ];
  };

  virtualisation.libvirtd.enable = true;
}
