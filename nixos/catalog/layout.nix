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
      "links"
      "nodered"
      "syncthing"
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
      "modem"
      "skynas"
      "traefik"
      "unifi"
      "zwavejs"
    ];
  }
]
