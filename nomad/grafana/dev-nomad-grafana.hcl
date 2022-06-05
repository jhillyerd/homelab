# Nomad dev agent config
client {
  host_volume "grafana-storage" {
    path = "/tmp/grafana-storage"
    read_only = false
  }
}
