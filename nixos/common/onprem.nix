# Setup for on-premises machines
{
  config,
  options,
  catalog,
  ...
}:
{
  networking = {
    search = [
      "home.arpa"
      "dyn.home.arpa"
    ];
    timeServers = [ "ntp.home.arpa" ] ++ options.networking.timeServers.default;
  };

  # Configure telegraf agent.
  roles.telegraf = {
    enable = true;
    influxdb = {
      urls = catalog.influxdb.urls;
      database = catalog.influxdb.telegraf.database;
      user = catalog.influxdb.telegraf.user;
      passwordFile = config.age.secrets.influxdb-telegraf.path;
    };
  };

  # Forward syslogs to promtail/loki.
  roles.log-forwarder = {
    enable = true;
    syslogHost = catalog.syslog.host;
    syslogPort = catalog.syslog.port;
  };

  programs.msmtp.accounts.default = {
    auth = false;
    host = catalog.smtp.host;
  };

  age.secrets = {
    influxdb-telegraf.file = ../secrets/influxdb-telegraf.age;
    wifi-env.file = ../secrets/wifi-env.age;
  };
}
