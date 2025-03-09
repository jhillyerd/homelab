# Common config shared among all machines
{
  pkgs,
  authorizedKeys,
  catalog,
  hostName,
  environment,
  ...
}:
{
  system.stateVersion = "24.11";

  imports = [
    ./common/packages.nix
    ./roles
  ];
  nixpkgs.overlays = [ (import ./pkgs/overlay.nix) ];
  nixpkgs.config.allowUnfree = true;

  nix = {
    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
      randomizedDelaySec = "20min";
    };

    settings.substituters = [ "http://nix-cache.service.skynet.consul?priority=10" ];
  };

  services.getty.helpLine = ">>> Flake node: ${hostName}, environment: ${environment}";

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  programs.command-not-found.enable = false; # not flake aware

  time.timeZone = "US/Pacific";

  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  environment.etc."issue.d/ip.issue".text = ''
    IPv4: \4
  '';
  networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";
  networking.firewall.checkReversePath = "loose";

  systemd.network.wait-online.ignoredInterfaces = [ catalog.tailscale.interface ];
}
