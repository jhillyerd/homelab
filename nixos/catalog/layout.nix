{ }:
[
  # Layout of services on the dashboard.
  {
    section = "Services";
    services = [
      "agent-zero"
      "fluidd"
      "forgejo"
      "homeassistant"
      "inbucket"
      "jellyfin"
      "links"
      "nodered"
      "openwebui"
      "radarr"
      "sonarr"
    ];
  }
  {
    section = "Cluster";
    services = [
      "consul"
      "grafana"
      "nomad"
      "proxmox"
      "traefik"
    ];
  }
  {
    section = "Infrastructure";
    services = [
      "llm"
      "mininas"
      "syncthing"
      "unifi"
      "zwavejs"
    ];
  }
]
