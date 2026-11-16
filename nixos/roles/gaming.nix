{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.roles.gaming;
in
{
  options.roles.gaming = {
    enable = mkEnableOption "Gaming: Steam + Heroic, with GameMode and MangoHud";
  };

  config = mkIf cfg.enable {
    # Steam's own module already turns on hardware.graphics (+32bit),
    # hardware.steam-hardware (controller udev rules) and 32-bit ALSA, and
    # pulls in gamescope only if gamescopeSession is enabled -- we don't
    # want a gamescope session, so leave that off and run games as ordinary
    # sway windows.
    programs.steam = {
      enable = true;

      # MangoHud and gamemoderun must be inside Steam's runtime environment
      # to be reachable from a game's launch options ("mangohud %command%").
      extraPackages = with pkgs; [
        mangohud
        gamemode # provides gamemoderun
      ];
    };

    # Feral GameMode: bumps the CPU governor, process priority and core
    # affinity for the duration of a game. The module creates the gamemode
    # group, the polkit actions and a cap_sys_nice gamemoded wrapper.
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      # Also expose the overlay tools outside of Steam (native and Heroic
      # launches). `gamemode` provides gamemoderun, gamemodelist and the
      # gamemoded daemon.
      mangohud
      gamemode

      heroic # Epic Games / GOG launcher
    ];

    # Attach ourselves to the group the gamemode module creates, rather than
    # reaching into users.users.james: adding a member to an existing group
    # cannot invent a user on a host that doesn't have one.
    users.groups.gamemode.members = [ "james" ];
  };
}
