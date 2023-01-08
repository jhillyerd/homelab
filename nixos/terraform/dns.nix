{ config, lib, catalog, ... }:
let
  inherit (lib) filterAttrs attrByPath mapAttrs';

  cfZoneId = "f97e67cee8c93d4d99480b99e30052d4";

  # Hostname for internal (tailnet) services.
  intHost = "web.bytemonkey.org";

  # Hostname for external (internet) services.
  extHost = "x.bytemonkey.org";
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
      # Services that requested a CNAME.
      internalServices = filterAttrs (n: svc: attrByPath [ "dns" "intCname" ] false svc) catalog.services;

      # Services to expose outside of our tailnet.
      externalServices = filterAttrs (n: svc: attrByPath [ "dns" "extCname" ] false svc) catalog.services;

      mkInternalServiceRecord = name: svc:
        {
          name = "${name}-int";
          value = {
            inherit name;

            type = "CNAME";
            value = intHost;
            ttl = 600;

            allow_overwrite = true;
            zone_id = cfZoneId;
          };
        };

      mkExternalServiceRecord = name: svc:
        {
          name = "${name}-ext";
          value = {
            name = "${name}.x";

            type = "CNAME";
            value = extHost;
            ttl = 600;

            allow_overwrite = true;
            zone_id = cfZoneId;
          };
        };
    in
    (mapAttrs' mkInternalServiceRecord internalServices)
    // (mapAttrs' mkExternalServiceRecord externalServices);
}
