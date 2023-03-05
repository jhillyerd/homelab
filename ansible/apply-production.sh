#!/usr/bin/env bash
# Usage:
#   apply-production.sh [limit host pattern] [playbook tag]

# Optionally limit applied hosts.
limit=""
if [ -n "$1" ]; then
  limit="--limit=$1"
fi

tags=""
if [ -n "$2" ]; then
  tags="--tags=$2"
fi

set -x

ansible-playbook site.yml --inventory hosts.yml $limit $tags
