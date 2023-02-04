# nixos flake

## Cachix

This flake sets up devenv for workstations, which is an expensive build.
Run `cachix use devenv` to enable the devenv build cache.

## Ways to use this flake

### Update NixOS channel

```sh
nix flake update
```

### Quick test VM

```sh
nix build ".#$host"
result/bin/run-$host-vm
```

### Push to running libvirtd or Hyper-V test VM

```sh
./deploy virt-$host root@$hostIP
```

or

```sh
./deploy hyper-$host root@$hostIP
```

See `../baseimage` for VM base images for intial boot.

### Push to running bare-metal prod machine

```sh
./deploy $host root@$hostIP
```

### Rebuild local system with specified host config

```sh
sudo nixos-rebuild --flake ".#$host" boot
```
