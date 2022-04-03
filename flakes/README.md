# nixos-minimal-raspberrypi3-flake

A minimal NixOS system flake for RPi 3.  Examples I found were either much
more elaborate, or for older systems like the Pi 2.

You will need to enable aarch64 emulation on your x86-64 NixOS host to build
this flake.  Doing so will let you take advantage of the public NixOS build
cache.

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

See `build.sh` and `deploy.sh` for examples of how to build an SD card image,
and how to push updates to a running Pi over the network.
