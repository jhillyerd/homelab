{ config, lib, catalog, ... }:
let
  inherit (lib) mapAttrs';

  cfZoneId = "f97e67cee8c93d4d99480b99e30052d4";

  # Hostname for internal (tailnet) services.
  intHost = "web.bytemonkey.org";
in
{
  variable.cf_api_token = {
    type = "string";
    sensitive = true;
  };

  terraform.required_providers = {
    cloudflare = {
      source = "cloudflare/cloudflare";
      version = "~> 3.0";
    };
  };

  provider.cloudflare = {
    api_token = "\${ var.cf_api_token }";
  };

  # Cloudflare DNS records.
  resource.cloudflare_record =
    let
      mkInternalServiceRecord = name: svc:
        {
          name = "${name}-int";
          value = {
            inherit name;

            value = intHost;
            type = "CNAME";
            ttl = 600;

            allow_overwrite = true;
            zone_id = cfZoneId;
          };
        };
    in
    mapAttrs' mkInternalServiceRecord catalog.services;
}
