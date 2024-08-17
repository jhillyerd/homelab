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

  # Cloudflare octodns config.
  "octodns/cloudflare-config.yaml" = {
    manager = {
      max_workers = 1;
      enable_checksum = true;
      processors = [ "meta" "preserve-names" ];
    };

    providers = {
      zones = {
        class = "octodns.provider.yaml.YamlProvider";
        directory = "./external-zones";
        default_ttl = 600;
        enforce_order = true;
      };

      cloudflare = {
        class = "octodns_cloudflare.CloudflareProvider";
        token = "env/CLOUDFLARE_TOKEN";
      };
    };

    zones = {
      "*" = {
        sources = [ "zones" ];
        targets = [ "cloudflare" ];
      };
    };

    processors = {
      meta = {
        class = "octodns.processor.meta.MetaProcessor";
        record_name = "octodns-meta";
        include_provider = true;
      };

      preserve-names = {
        class = "octodns.processor.filter.NameRejectlistFilter";
        rejectlist = [ "home" ];
      };
    };
  };

  "octodns/internal-zones/bytemonkey.org.yaml" = import ./bytemonkey-int.nix inputs target;
  "octodns/internal-zones/home.arpa.yaml" = import ./home.nix inputs target;

  "octodns/external-zones/bytemonkey.org.yaml" = import ./bytemonkey-ext.nix inputs target;
}
