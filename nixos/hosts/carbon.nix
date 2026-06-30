{ ... }:
{
  imports = [ ../common.nix ];

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
