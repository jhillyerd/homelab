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
  - Include secrets through templates and Consul key-value store

## Resource Management
- Specify CPU in MHz (e.g., `cpu = 1000 # MHz`)
- Specify memory in MB (e.g., `memory = 512 # MB`)
- Set reasonable limits based on application requirements

## Volume Management
- Use host volumes for persistent data storage:
  - `volume "name" { type = "host", source = "volume-name" }`
- Mount volumes in tasks with `volume_mount`

## Security and Templates
- Use templates for configuration files:
  - Use `template { data = <<EOT> ... EOT }` blocks
  - Reference secrets from Consul key-value store with `{{key "secret/path"}}`
  - Include proper template destinations

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
4. **Persistent Data**: Host volumes for data persistence
5. **Security**: Secrets management through Consul key-value store
6. **Health Monitoring**: Comprehensive health checks for services