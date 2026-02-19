{ }:
[
  # Layout of services on the dashboard.
  {
    section = "Services";
    services = [
      "agent-zero"
      "fluidd"
      "forgejo"
      "grafana"
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
      "argocd"
      "consul"
      "dockreg"
      "nomad"
      "proxmox"
    ];
  }
  {
    section = "Infrastructure";
    services = [
      "llm"
      "mininas"
      "skynas"
      "syncthing"
      "traefik"
      "unifi"
      "zwavejs"
    ];
  }
]
