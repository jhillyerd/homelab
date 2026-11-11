# homelab

- `ansible`: My ansible config to capture telemetry and syslogs from Raspberry
  Pis.
- `bin`: Ops scripts: `deploy` a host, `dns-sync` to push DNS zones,
  `gen_passwords` to render secrets templates.
- `consul`: Consul ACL policies.
- `esphome`: My esphome (ESP32 + Home Assistant) configs.
- `flake-modules`: flake-parts modules wiring up hosts, packages and the
  dev shell for the root `flake.nix`.
- `nomad`: Nomad job specs, ACL policies, helper scripts, and the cluster
  CA material under `certs/`.
- `nixos`: My NixOS home lab system configs.
- `pkgs`: Nix packages owned by this repo, exposed via the flake and as an
  overlay to hosts.

## Usage

Enter the dev shell with direnv or `nix develop`, then:

- `nixos-rebuild --flake .#<host> build` — validate/build a host config
- `bin/deploy <host> [root@<target>]` — build and push to a running host
- `bin/dns-sync` — build and push DNS zones (octodns; see `nixos/confgen`)
- `nix build .#confgen` — regenerate config outputs (DNS zone YAML, etc)

## Diagrams

### Machines

```mermaid
graph TD
    wan((WAN)) --- gw{{Gateway}}
    gw --- lan{LAN}
    nc1("nc-um350-1<br/>(nomad client)") --- lan
    nc2("nc-um350-2<br/>(nomad client)") --- lan
    nas("mininas<br/>(NAS)") --- lan
    lan --- pve1
    lan --- pve3
    lan --- pve4
    subgraph pve1 ["pve1 (16GB hypervisor)"]
        direction RL
        witness("witness<br/>(nomad server)")
    end
    subgraph pve3 ["pve3 (64GB hypervisor)"]
        direction RL
        fastd("fastd<br/>(database)")
        kube1("kube1")
        nc-virt-1("nc-virt-1<br/>(nomad client)")
        web("web")
    end
    subgraph pve4 ["pve4 (64GB hypervisor)"]
        direction RL
        ci-runner1("ci-runner1<br/>(forgejo)")
        kube2("kube2")
        metrics("metrics")
        unifi("unifi")
    end
```

### Monitoring

```mermaid
graph LR
    ha([home assistant]) ---> influxdb
    subgraph nixos ["all nixos nodes"]
        nix-telegraf([telegraf])
        nix-syslog([syslog])
    end
    subgraph nomad-nodes ["all nomad client nodes"]
        nomad([nomad client]) --> nomad-telegraf([telegraf])
        docker([docker logs]) --> nomad-vector([vector])
    end
    subgraph metrics ["node: metrics"]
        metrics-telegraf(["telegraf<br/>- ping checks<br/>- url checks"])
        metrics-telegraf --> influxdb([influxdb])
        loki([loki])
        nix-telegraf ---> influxdb
        nix-syslog ---> loki
        nomad-telegraf --> influxdb
        nomad-vector --> loki
    end
    influxdb -.-> grafana([grafana])
    loki -.-> grafana
```
