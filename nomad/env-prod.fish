set -x NOMAD_ADDR https://nomad.service.consul:4646
set -x NOMAD_CACERT ~/secrets/nomad/ca/nomad-ca.pem
set -x NOMAD_CLIENT_CERT ~/secrets/nomad/cli.pem
set -x NOMAD_CLIENT_KEY ~/secrets/nomad/cli-key.pem
set -x NOMAD_TOKEN (cat ~/secrets/nomad/manager-token)
