#!/bin/sh

set -x
docker run --rm --net=host -v "${PWD}":/config -it ghcr.io/esphome/esphome
