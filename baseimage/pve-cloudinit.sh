#!/usr/bin/env bash
# Imports a cloud-init disk image into Proxmox VE; must be run on PVE host.
#
# Usage:
#   pve-cloudinit.sh <VMID> [VM image path]

set -e

function fail {
  echo "$1" >&2
  exit 1
}

id="$1"
image="${2:-/root/nixos.qcow2}"

test -n "$id" || fail "Missing VM ID (first argument)"
test -r "$image" || fail "Image '$image' image is unreadable"

set -x

qm create $id --memory 2048 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
qm set $id --scsi0 "local-lvm:0,discard=on,import-from=$image"
qm set $id --ide2 local-lvm:cloudinit
qm set $id --boot order=scsi0 --ostype l26
qm set $id --serial0 socket --vga serial0
qm set $id --ipconfig0 ip=dhcp
qm set $id --ciupgrade 0 --agent 1
qm cloudinit update $id
qm template $id
