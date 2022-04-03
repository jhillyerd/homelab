#!/bin/sh
# build.sh <host-name>:
#  Builds the image for the specified host name.
#

host="$1"

nix build ".#images.$host"
