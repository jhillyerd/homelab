# Servers advertise mesh IPs (wireguard-mesh-plan phase 2), so
# nomad.service.consul resolves to mesh-only addresses that workstations
# cannot reach. Dial a server directly instead: its LAN IP via the
# *.home.arpa cert SAN, kept open as the debugging path (phase 5).
set -x NOMAD_ADDR https://witness.home.arpa:4646
set -x NOMAD_CACERT ~/secrets/nomad/ca/nomad-ca.pem
set -x NOMAD_CLIENT_CERT ~/secrets/nomad/cli.pem
set -x NOMAD_CLIENT_KEY ~/secrets/nomad/cli-key.pem
set -x NOMAD_TOKEN (cat ~/secrets/nomad/manager-token)
