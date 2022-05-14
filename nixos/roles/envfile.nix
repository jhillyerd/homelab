{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.envfile;

  envfileType = with types;
    submodule ({ config, ... }: {
      options = {
        name = mkOption {
          type = str;
          default = config._module.args.name;
          description = "Name of the envfile";
        };

        secretPath = mkOption {
          type = path;
          description = "Path of the decrypted (agenix) secret";
        };

        varName = mkOption {
          type = str;
          description = ''
            Variable name to populate or replace with secret.
            Ignored if `content` is specified.
          '';
          default = "SECRET";
        };

        content = mkOption {
          type = nullOr str;
          description =
            "Content of envfile.  If null, content will be <varName>=<secret>";
          default = null;
        };

        quoteValue = mkOption {
          type = bool;
          description = ''
            Surround the value with double-quotes if true.
            Should be false for docker.
          '';
          default = true;
        };

        file = mkOption {
          type = str;
          description = "Path (with file) to store generated envfile";
          default = "${cfg.directory}/${config.name}";
        };

        owner = mkOption {
          type = str;
          description = "User to own the envfile";
          default = "0";
        };

        group = mkOption {
          type = str;
          description = "Group to own the envfile";
          default = "0";
        };

        mode = mkOption {
          type = str;
          description = "Permissions mode for the envfile";
          default = "0400";
        };
      };
    });
in
{
  options.roles.envfile = {
    directory = mkOption {
      type = types.path;
      description = "Directory to create envfiles within";
      default = "/run/envfile";
    };

    files = mkOption {
      type = types.attrsOf envfileType;
      description = "Environment files to generate";
      default = { };
    };
  };

  config = mkIf (cfg.files != { }) {
    # Create an environment file during activation for each entry.
    system.activationScripts = attrsets.mapAttrs'
      (name: entry:
        let
          entryDir = dirOf entry.file;

          quote = if entry.quoteValue then ''"'' else "";

          prefix = ''
            mkdir -p "${entryDir}"
            chmod 701 "${entryDir}"
          '';

          postfix = ''
            chmod ${entry.mode} "${entry.file}"
            chown ${entry.owner}:${entry.group} "${entry.file}"
          '';

          fname = "envfile-" + name;

          contentFile = pkgs.writeText fname entry.content;
        in
        {
          name = fname;

          value = stringAfter [ "etc" "agenix" "agenixRoot" ]
            (if entry.content == null then
            # Generate single line envfile.
              ''
                ${prefix}
                cat > "${entry.file}" <<EOT
                ${entry.varName}=${quote}$(< ${entry.secretPath})${quote}
                EOT
                ${postfix}
              '' else
            # Replace SECRET in provided content.
              ''
                ${prefix}
                ${entry.varName}="$(< ${entry.secretPath})" ${pkgs.envsubst}/bin/envsubst \
                  -i "${contentFile}" -o "${entry.file}"
                ${postfix}
              '');
        })
      cfg.files;
  };
}
