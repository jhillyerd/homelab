{
  nodes = {
    fractal.ip = "100.112.232.73";
    nexus.ip = "100.80.202.97";
    nc-um350-1.ip = "100.109.33.10";
  };

  influxdb = rec {
    host = "nexus";
    port = 8086;
    telegraf.user = "telegraf";
    telegraf.database = "telegraf-hosts";
    urls = [ "http://${host}:${toString port}" ];
  };

  syslog.host = "nexus";
  syslog.port = 1514;

  smtp.host = "nexus";

  tailscale.interface = "tailscale0";
}
