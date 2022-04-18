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
          description = "Environment variable name to populate with secret";
          default = "SECRET";
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
in {
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
    system.activationScripts = attrsets.mapAttrs' (name: entry:
      let
        entryDir = dirOf entry.file;
        quote = if entry.quoteValue then ''"'' else "";
      in {
        name = "envfile-" + name;
        value = stringAfter [ "etc" "agenix" "agenixRoot" ] ''
          mkdir -p "${entryDir}"
          chmod 700 "${entryDir}"
          cat > "${entry.file}" <<EOT
          ${entry.varName}=${quote}$(< ${entry.secretPath})${quote}
          EOT
          chmod ${entry.mode} "${entry.file}"
          chown ${entry.owner}:${entry.group} "${entry.file}"
        '';
      }) cfg.files;
  };
}
