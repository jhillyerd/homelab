# Common config shared among all machines
{
  authorizedKeys,
  catalog,
  hostName,
  lib,
  pkgs,
  ...
}:
{
  system.stateVersion = "25.11";

  imports = [
    ./packages.nix
    ../roles
  ];
  nixpkgs.overlays = [ (import ../../pkgs/overlay.nix) ];
  nixpkgs.config.allowUnfree = true;

  environment.shellAliases = {
    la = "ls -lAh";
  };

  nix = {
    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
      randomizedDelaySec = "20min";
    };

    settings = {
      download-buffer-size = 201326592;
      max-jobs = lib.mkDefault 4;

      # Local cache.nixos.org proxy (nomad/nix-cache.nomad, fronted by fabio).
      # Safe since nix 2.34 falls back to public caches when it is
      # unreachable (NixOS/nix#13301).
      substituters = [
        "http://nix-cache.service.skynet.consul?priority=10"
        "https://cache.nixos.org"
      ];
    };
  };

  services.getty.helpLine = ">>> Flake node: ${hostName}";

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  time.timeZone = "US/Pacific";

  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  environment.etc."issue.d/ip.issue".text = ''
    IPv4: \4
  '';
  networking.dhcpcd.runHook = "${pkgs.util-linux}/bin/agetty --reload";
  networking.firewall.checkReversePath = "loose";

  systemd.network.wait-online.ignoredInterfaces = [ catalog.tailscale.interface ];
}
