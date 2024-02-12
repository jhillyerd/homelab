# homelab

- `ansible`: My ansible config to capture telemetry and syslogs from Raspberry
  Pis.
- `baseimage`: Flakes for generating minimal NixOS images for VMs and SD cards.
- `esphome`: My esphome (ESP32 + Home Assistant) configs.
- `nixos`: My NixOS home lab system configs flake.

## Diagrams

### Machines

```mermaid
graph TD
    wan((WAN)) --- gw{{Gateway}}
    gw --- lan{LAN}
    nc1("nc-um350-1<br/>(nomad client)") --- lan
    nc2("nc-um350-2<br/>(nomad client)") --- lan
    nas("skynas<br/>(NAS)") --- lan
    lan --- pve1
    lan --- pve2
    lan --- pve3
    subgraph pve1 ["pve1 (hypervisor)"]
        direction RL
        nexus
        witness
    end
    subgraph pve2 ["pve2 (hypervisor)"]
        direction RL
        kube2
        scratch
    end
    subgraph pve3 ["pve3 (hypervisor)"]
        direction RL
        ci-runner1
        eph
        kube1
        metrics
        web
    end
```
