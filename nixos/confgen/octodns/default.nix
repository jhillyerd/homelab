{ catalog, ... }@inputs:
let
  # Nameserver to push records to.
  target = catalog.dns.ns1;
in
{
  # Internal octodns config.
  "octodns/internal-config.yaml" = {
    manager = {
      max_workers = 1;
      enable_checksum = true;
      processors = [ "meta" ];
    };

    providers = {
      zones = {
        class = "octodns.provider.yaml.YamlProvider";
        directory = "./internal-zones";
        default_ttl = 600;
        enforce_order = true;
      };

      nexus_bind = {
        class = "octodns_bind.Rfc2136Provider";
        host = target;
        key_name = "env/BIND_KEY_NAME";
        key_secret = "env/BIND_KEY_SECRET";
      };
    };

    zones = {
      "*" = {
        sources = [ "zones" ];
        targets = [ "nexus_bind" ];
      };
    };

    processors = {
      meta = {
        class = "octodns.processor.meta.MetaProcessor";
        record_name = "octodns-meta";
        include_provider = true;
      };
    };
  };

  "octodns/internal-zones/bytemonkey.org.yaml" = import ./bytemonkey.nix inputs target;
  "octodns/internal-zones/home.arpa.yaml" = import ./home.nix inputs target;
}
