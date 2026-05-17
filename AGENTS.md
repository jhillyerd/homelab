# NixOS Configuration Guidelines

## Commands
- Test that a host builds: `cd nixos; nixos-rebuild --flake .#<host> build`

## Constraints
- Do not run nixos-rebuild with the `switch` or `boot` options, we are not
  always logged into the host we are configuring.
- Do not rebuild multiple hosts just to check the config, this can take a
  long time.


# Nomad Job Authoring Guidelines

## Basic Job Structure
- Use `job "job-name" { }` with descriptive names
- Specify datacenters (e.g., `datacenters = ["skynet"]`)
- Define job type (`service` or `system`)

## Constraints
- Always include kernel name constraint: `attribute = "${attr.kernel.name}", value = "linux"`
- Include architecture constraint for x86_64 systems: `attribute = "${attr.kernel.arch}", value = "x86_64"`

## Group Configuration
- Use descriptive group names (e.g., `group "grafana" { }`)
- For single instance services, set `count = 1`
- Define network configuration:
  - `mode = "host"` for services that need direct network access
  - `mode = "bridge"` for containerized applications with isolated networking
  - Define port mappings with `port "name" { to = port }`

## Service Definitions
- Include service blocks with appropriate names and ports
- Add service tags for integration with Traefik or other reverse proxies
- Implement health checks for services:
  - HTTP checks with appropriate paths, intervals, and timeouts
  - Specify check types (`http`, `tcp`, etc.)

## Task Configuration
- Use Docker driver for containerized applications
- Configure container images and ports
- Set appropriate resource limits (CPU and memory)
- Use environment variables for configuration:
  - Use `${NOMAD_PORT_*}` for dynamic port binding
  - Include secrets through templates using Nomad Variables or Consul key-value store

## Resource Management
- Specify CPU in MHz (e.g., `cpu = 1000 # MHz`)
- Specify memory in MB (e.g., `memory = 512 # MB`)
- Set reasonable limits based on application requirements

## Volume Management

### Persistent data: Docker bind mounts (preferred)
Use `mount` blocks inside `task -> config` to bind-mount host paths into containers:
```hcl
# Inside task -> config block
mount {
  type     = "bind"
  source   = "/mnt/nomad-volumes/<service>/<subpath>"
  target   = "/container/path"
  readonly = false
}
```
- All persistent data lives under `/mnt/nomad-volumes/<service>/`, which is an NFS mount
  (see `nixos/roles/nomad.nix`), not host-local storage
- Single-volume services mount from `/mnt/nomad-volumes/<service>` directly
- Multi-volume services use subdirectories (e.g., `homeassistant/data`, `homeassistant/piper`)

### Config injection via bind mounts
For containers that expect config at a specific path managed by their entrypoint,
template into `secrets/` then bind-mount over the expected path:
```hcl
# Template into Nomad's secrets directory
# Inside template block
destination = "secrets/settings.yml"

# Mount it where the container expects it
mount {
  type     = "bind"
  source   = "secrets/settings.yml"
  target   = "/etc/someapp/config.yml"
  readonly = false
}
```
This avoids needing persistent storage just for config files.

### Nomad native volumes (for special cases)
Use group-level `volume` blocks with task-level `volume_mount` for host volumes registered
in the Nomad client config (e.g., Docker socket access):
```hcl
# At group level
volume "docker-sock" {
  type      = "host"
  source    = "docker-sock-ro"  # references a host_volume in Nomad client config
  read_only = true
}

# Inside task block
volume_mount {
  volume      = "docker-sock"
  destination = "/var/run/docker.sock"
  read_only   = true
}
```

### Ephemeral disk
Use `ephemeral_disk` for data that should survive task restarts but doesn't need a
persistent bind mount:
```hcl
ephemeral_disk {
  sticky  = true
  migrate = true   # optional, set to false if not needed
  size    = 150    # MB
}
```
- **Note**: Canary updates (`canary = 1`) are incompatible with `sticky = true`; set
  `canary = 0` when using sticky ephemeral disk

## Security and Templates
- Use templates for configuration files:
  - Use `template { data = <<EOT> ... EOT }` blocks
  - Include proper template destinations
- **Template destinations**:
  - Use `secrets/` for templates containing secrets (restricted permissions, not exposed via API)
  - Use `local/` for non-sensitive config
- **Secrets management** — two options:
  - **Nomad Variables** (preferred for new jobs): `{{ with nomadVar "nomad/jobs/<job>" }}{{ .key }}{{ end }}`
    - Store via: `nomad var put nomad/jobs/<job> key=value`
    - Job-scoped, supports ACL restrictions per path
  - **Consul KV**: `{{key "secrets/path"}}` (legacy, still used in existing jobs)

### Nomad Variables: Job-scoped secrets
By default, each job can only read variables at its own path (`nomad/jobs/<job-name>`).
No additional ACL configuration is needed for this case.
```hcl
# In the template block:
{{ with nomadVar "nomad/jobs/myjob" }}{{ .api_key }}{{ end }}
```
```bash
# Store the secret:
nomad var put nomad/jobs/myjob api_key=xxx
```

### Nomad Variables: Shared secrets across jobs
When multiple jobs need access to the same secret, use a shared variable path
(e.g., `influxdb/telegraf`) and create an ACL policy to grant read access.

**1. Define the ACL policy** (`nomad/acl/<name>-policy.hcl`):
```hcl
namespace "default" {
  variables {
    path "influxdb/*" {
      capabilities = ["read"]
    }
  }
}
```
Note: variable paths never start with a leading `/`.

**2. Apply the policy, scoped to the job(s) that need access:**
```bash
# Scope to a specific job (uses Nomad workload identities — no manual tokens needed)
nomad acl policy apply \
  -namespace default -job speedflux \
  shared-influxdb-read nomad/acl/shared-variables-policy.hcl

# Scope to all tasks in a group:
nomad acl policy apply -namespace default -job <job> -group <group> <name> <file>

# Scope to a specific task:
nomad acl policy apply -namespace default -job <job> -group <group> -task <task> <name> <file>
```

**3. Store the shared variable:**
```bash
nomad var put influxdb/telegraf password=xxx
```

**4. Reference in templates:**
```hcl
{{ with nomadVar "influxdb/telegraf" }}{{ .password }}{{ end }}
```

**Backup:** ACL policy source files live in `nomad/acl/` (in git). Nomad Variables
are only in Nomad's Raft store — use `nomad operator snapshot save` for disaster recovery.

## Logging
- Add log configuration for long-running services:
  - `logs { max_files = 10, max_file_size = 15 }`

## Advanced Features
- Include Consul integration for service discovery
- Configure Connect for service mesh capabilities
- Use multi-group deployments for complex applications
- Implement update strategies for critical services

## Key Patterns from Your Setup
1. **Service Discovery**: Consul integration is used for service discovery
2. **Reverse Proxy Integration**: Traefik tags for routing
3. **Service Mesh**: Connect configuration for microservices
4. **Persistent Data**: Docker bind mounts from NFS-backed `/mnt/nomad-volumes/<service>/`
5. **Security**: Secrets via Nomad Variables (preferred) or Consul key-value store
6. **Health Monitoring**: Comprehensive health checks for services
