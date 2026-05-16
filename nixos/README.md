# nixos flake

## Terminology

Knowing how I use these terms will better help you understand the layout
of this flake:

- catalog: The high level configuration of my homelab:
  - common: configuration that can be referenced by any part of this flake.
  - nodes: combines _host_, _hw_, and network configuration into a deployable
    NixOS configuration.
  - services: defines how a particular service may be accessed, including
    load-balanced URLs, whether to generate DNS entries, and the icon to display
    on my internal homepage.
- host: A grouping of _roles_ and _services_ that will be applied to one or
  more _nodes_.  A _node_ may only have a single host type.
- hw: Hardware configuration for physical and virtual machines.
- node: A specific VM or machine on my network.
- role: A nix module configuring one or more _services_ for one or more hosts.
- service: Standard nix modules for configuring services.

## Ways to use this flake

### Update NixOS channel

```sh
nix flake update
```

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

### Build and restore Proxmox image for host

```sh
nixos-rebuild build-image --image-variant proxmox --flake .#$host
scp vzdump-qemu-nixos-NNNN.vma.zst root@proxmox-host:

# On Proxmox host
qmrestore ./vzdump-qemu-nixos-NNNN.vma.zst <vmid>
```

You may then use the proxmox web UI to convert to template, and set
`Hardware: Display` to `Serial terminal 0`.

### Register u2f key for user

Allows for touch-based auth for sudo and polkit (including 1Password.)

```sh
mkdir -p ~/.config/Yubico
pamu2fcfg > ~/.config/Yubico/u2f_keys
chmod 600 ~/.config/Yubico/u2f_keys
```
