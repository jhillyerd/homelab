{ ... }: {
  # Telegraf monitoring config.
  http_response = [
    {
      # TODO Give Consul a LB entry.
      urls = [ "http://nexus.bytemonkey.org:8500/ui/" ];
      response_status_code = 200;
    }
    {
      urls = [ "http://demo.inbucket.org/status" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://dockreg.bytemonkey.org/v2/" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://gitea.bytemonkey.org" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://grafana.bytemonkey.org/" ];
      response_status_code = 401;
    }
    {
      urls = [ "https://homeassistant.bytemonkey.org/" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://inbucket.bytemonkey.org/" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://nodered.bytemonkey.org" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://nomad.bytemonkey.org/ui/" ];
      response_status_code = 200;
    }
    {
      urls = [ "http://octopi.home.arpa" ];
      response_status_code = 302;
    }
    {
      urls = [ "https://zwavejs.bytemonkey.org/" ];
      response_status_code = 200;
    }
  ];

  ping = [
    "gateway.home.arpa"
    "nexus.home.arpa"
    "nc-um350-1.home.arpa"
    "nc-um350-2.home.arpa"
    "octopi.home.arpa"
    "pve1.home.arpa"
    "pve2.home.arpa"
    "pve3.home.arpa"
    "skynas.home.arpa"
    "web.home.arpa"
  ];
}
