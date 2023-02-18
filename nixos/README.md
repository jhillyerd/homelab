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

See `../baseimage` for intial boot VM base images.

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
