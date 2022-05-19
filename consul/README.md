In additional to the token and policy created by `create-agent-poltok`,
you'll need to have some nomad specific policies that can be applied to the
tokens.  This is easier to do in the consul web UI for a small number of
nodes.

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
