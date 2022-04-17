{ config, pkgs, lib, ... }:
with lib;
let cfg = config.roles.envfile;
in {
  options.roles.envfile = {
    files = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
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

            targetDirectory = mkOption {
              type = str;
              description = "Directory to store generated envfile into";
              default = "/run/envfile";
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
      description = "Environment files to generate";
      default = { };
    };
  };

  config = mkIf (cfg.files != { }) {
    # Create an environment file during activation for each entry.
    system.activationScripts = attrsets.mapAttrs' (name: file:
      let
        envFile = file.targetDirectory + "/" + name;
        quote = if file.quoteValue then ''"'' else "";
      in {
        name = "envfile-" + name;
        value = stringAfter [ "etc" "agenix" "agenixRoot" ] ''
          mkdir -p "${file.targetDirectory}"
          chmod 700 "${file.targetDirectory}"
          cat > "${envFile}" <<EOT
          ${file.varName}=${quote}$(< ${file.secretPath})${quote}
          EOT
          chmod ${file.mode} "${envFile}"
          chown ${file.owner}:${file.group} "${envFile}"
        '';
      }) cfg.files;
  };
}
