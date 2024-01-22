# nixos flake

## Cachix

This flake sets up devenv for workstations, which is an expensive build.
Run `cachix use devenv` to enable the devenv build cache.

## Ways to use this flake

### Update NixOS channel

```sh
nix flake update
```

### Run a quick test VM

```sh
nix build ".#$host"
result/bin/run-$host-vm
```

### Push to running libvirtd or Hyper-V *test* VM

```sh
./deploy virt-$host root@$hostIP
```

or

```sh
./deploy hyper-$host root@$hostIP
```

See `../baseimage` for initial boot base images for VMs.

### Push to running bare-metal prod machine

```sh
./deploy $host root@$hostIP
```

### Rebuild localhost with specified host config

```sh
sudo nixos-rebuild --flake ".#$host" boot
```

### Build SD card image for host

```sh
nix build ".#images.$host"
sudo dd bs=4M conv=fsync if=result/sd-image/*-linux.img of=/dev/sdX
```

## Convenience scripts

When iterating on my homelab, I often repeat the following steps:

1. Check an existing node for failed services, uptime, and disk space
2. Deploy an updated NixOS config to the host
3. Check for failed services
4. Reboot the node
5. Check for failed services, and that the uptime went to zero

The scripts in this directory simplify the process to:

```sh
host=<hostname>
./status
./deploy
./status
./restart
./status
```

Additionally, `deploy` adds an entry to log.txt with the git commit deployed,
helping me identify out-of-date nodes.  Example:

```
web          [2024-01-18 13:41:16 -0800] e38c39c proxmox: use serial console
nexus        [2024-01-21 16:03:31 -0800] 0769380 dns: add kube records
nc-um350-2   [2024-01-21 16:39:14 -0800] ebece50 dns: forward local zones on nomad clients
nc-um350-1   [2024-01-21 16:39:14 -0800] ebece50 dns: forward local zones on nomad clients
metrics      [2024-01-21 16:47:48 -0800] da374b9 k3s: add first node
kube1        [2024-01-22 10:39:26 -0800] 266e67f catalog: organize default.nix
```
