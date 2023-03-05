#!/usr/bin/env bash

# Optionally limit applied hosts.
limit=""
if [ -n "$1" ]; then
  limit="--limit=$1"
fi

ansible-playbook site.yml --inventory hosts.yml $limit
