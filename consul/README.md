In additional to the token and policy created by `create-agent-poltok`,
you'll need to have some nomad specific policies that can be applied to the
tokens.  This is easier to do in the consul web UI for a small number of
nodes.

## `consul-metrics` policy

Read-only policy used by Prometheus (on the metrics host) to scrape
`/v1/agent/metrics?format=prometheus` from every agent, and by the
consul-exporter Nomad job to read the catalog and service health.  The
Prometheus token is stored at `nixos/secrets/consul-metrics-token.age`
(encrypted for `group.home`); the exporter token lives in the Nomad variable
`nomad/jobs/consul-exporter`.

```bash
consul acl policy create -name consul-metrics -rules @consul-metrics-policy.hcl
consul acl token create -policy-name consul-metrics -description "prometheus scrape token"
# Store the SecretID with:
agenix -e nixos/secrets/consul-metrics-token.age   # (from nixos/secrets)
# Exporter token instead goes to the nomad variable:
nomad var put nomad/jobs/consul-exporter token=<secret>
```


## `nomad-server` policy

```hcl
agent_prefix "" {
  policy = "read"
}

node_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "write"
}

acl = "write"
operator = "write"
```

## `nomad-client` policy

```
agent_prefix "" {
  policy = "read"
}

node_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "write"
}

key_prefix "" {
  policy = "read"
}
```
