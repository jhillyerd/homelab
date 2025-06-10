{ }:
[
  # Layout of services on the dashboard.
  {
    section = "Services";
    services = [
      "fluidd"
      "forgejo"
      "grafana"
      "homeassistant"
      "inbucket"
      "nodered"
      "syncthing"
    ];
  }
  {
    section = "Cluster";
    services = [
      "consul"
      "nomad"
      "proxmox"
      "dockreg"
      "argocd"
    ];
  }
  {
    section = "Infrastructure";
    services = [
      "modem"
      "skynas"
      "traefik"
      "unifi"
      "zwavejs"
    ];
  }
]
