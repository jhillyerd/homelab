# A scratch host for building up new service configurations.
{ config, pkgs, lib, self, catalog, util, ... }: {
  imports = [ ../common.nix ];

  # boot.supportedFilesystems = [ "zfs" ];
  # boot.zfs.extraPools = [ "zpool1" "zpool2" ];

  # networking.hostId = "f40588ab";

  # services.syncoid = {
  #   enable = true;
  #   interval = "minutely";

  #   localSourceAllow = [
  #     "bookmark"
  #     "hold"
  #     "mount" # added
  #     "send"
  #     "snapshot"
  #     "destroy"
  #   ];

  #   localTargetAllow = [
  #     "change-key"
  #     "compression"
  #     "create"
  #     "destroy" # added
  #     "mount"
  #     "mountpoint"
  #     "receive"
  #     "rollback"
  #   ];

  #   commands.fast = {
  #     source = "zpool1/fast";
  #     target = "zpool2/fast";
  #   };
  # };

  systemd.network.networks = util.mkClusterNetworks self;

  networking.firewall.enable = true;
}
