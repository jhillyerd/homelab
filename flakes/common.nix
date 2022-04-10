{ pkgs, lib, ... }: {
  boot.supportedFilesystems = [ "vfat" "f2fs" "ntfs" "cifs" ];

  services.openssh.enable = true;

  services.tailscale.enable = true;

  time.timeZone = "US/Pacific";

  users.users.root.openssh.authorizedKeys.keys =
    lib.splitString "\n" (builtins.readFile ../authorized_keys.txt);
}
