# Allow jobs to read shared variable paths outside their own job scope.
# Variables live in the "default" namespace and use paths like
# "influxdb/telegraf" to group shared secrets by service.

namespace "default" {
  variables {
    path "influxdb/*" {
      capabilities = ["read"]
    }
  }
}
