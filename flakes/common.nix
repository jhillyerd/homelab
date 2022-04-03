{ pkgs, lib, ... }: {
  boot.supportedFilesystems = [ "vfat" "f2fs" "ntfs" "cifs" ];

  # SSH is required to deploy updates over the network.
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys =
    lib.splitString "\n" (builtins.readFile ./authorized_keys.txt);
}
