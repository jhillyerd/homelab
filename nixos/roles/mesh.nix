{
  config,
  lib,
  self,
  hostName,
  catalog,
  ...
}:
with lib;
let
  cfg = config.roles.mesh;

  # Mesh members are catalog nodes with an ip.wg address; the catalog is
  # the single source of truth (see homelab/plans/wireguard-mesh-plan.md).
  members = filterAttrs (_: node: node ? ip.wg) catalog.nodes;

  peers = removeAttrs members [ hostName ];

  # Jobs bind mesh-only ports (Nomad host_network "mesh") and agents
  # advertise mesh IPs (roles/nomad.nix), so wg0 must exist before the
  # nomad and traefik daemons start; traefik dials backends over the mesh
  # from phase 3.
  wgUnit = "wireguard-${catalog.mesh.interface}.service";
in
{
  options.roles.mesh = {
    enable = mkOption {
      type = types.bool;
      default = self ? ip.wg;
      description = "WireGuard mesh member; set ip.wg in the node catalog to join.";
    };
  };

  config = mkIf cfg.enable {
    # A member without a public key would be silently unreachable from the
    # rest of the mesh — make it an eval error naming the node instead.
    assertions =
      mapAttrsToList
        (name: _: {
          assertion = (members.${name}.wg or { }) ? pub;
          message = "mesh member '${name}' has no wg.pub in nixos/catalog/nodes.nix — run bin/wg-keygen ${name}";
        })
        members;

    age.secrets.mesh-wg-key.file = ../secrets/mesh-wg-key-${hostName}.age;

    networking.wireguard.interfaces.${catalog.mesh.interface} = {
      ips = [ "${self.ip.wg}/32" ];
      listenPort = catalog.mesh.port;
      mtu = catalog.mesh.mtu;
      privateKeyFile = config.age.secrets.mesh-wg-key.path;

      peers = mapAttrsToList
        (_: node: {
          publicKey = node.wg.pub;
          allowedIPs = [ "${node.ip.wg}/32" ];
          endpoint = "${node.ip.priv}:${toString catalog.mesh.port}";
        })
        peers;
    };

    networking.firewall = {
      # Trust traffic arriving over the mesh.
      trustedInterfaces = [ catalog.mesh.interface ];

      # Peers dial our LAN address to reach us.
      allowedUDPPorts = [ catalog.mesh.port ];
    };

    # No explicit NAT for alloc egress is needed: Nomad's default CNI
    # config (bridge + firewall plugins) installs per-alloc FORWARD accept
    # and MASQUERADE rules that are interface-agnostic, so bridge-mode
    # allocations already reach wg0 peers with the host's ip_forward on
    # (verified from a running alloc, wireguard-mesh-plan phase 2).

    systemd.services = mkMerge [
      (mkIf config.services.nomad.enable {
        nomad = {
          after = [ wgUnit ];
          wants = [ wgUnit ];
        };
      })
      (mkIf config.services.traefik.enable {
        traefik = {
          after = [ wgUnit ];
          wants = [ wgUnit ];
        };
      })
    ];
  };
}
