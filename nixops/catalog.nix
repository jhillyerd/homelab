{
  influxdb = rec {
    host = "nexus";
    port = 8086;
    telegraf.user = "telegraf";
    telegraf.database = "telegraf-hosts";
    urls = [ "http://${host}:${toString port}" ];
  };

  syslog.host = "nexus";
  syslog.port = 1514;
}
