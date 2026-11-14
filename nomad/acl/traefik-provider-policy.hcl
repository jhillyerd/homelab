# Read-only Nomad API access for the traefik provider running on the web
# host (wireguard-mesh-plan phase 3). Traefik lists and reads native
# service registrations in the default namespace; no write capabilities.
#
# Apply: nomad acl policy apply traefik-provider nomad/acl/traefik-provider-policy.hcl
# Token:  nomad acl token create -name "traefik provider" -policy traefik-provider
#         (store the SecretID in nixos/secrets/traefik-nomad-token.age)
namespace "default" {
  capabilities = ["read-job", "list-jobs"]
}
