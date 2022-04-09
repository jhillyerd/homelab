#!/bin/sh
# deploy.sh <host-name> root@<target-host>:
#  Builds the flake for host-name locally and deploys to target-host

host="$1"
target="$2"

nixos-rebuild --flake ".#$host" --target-host "$target" \
  --build-host localhost switch
