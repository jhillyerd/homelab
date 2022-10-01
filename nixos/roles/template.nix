{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.roles.template;

  # Configuration for an individual template file.
  fileConfig = with types;
    submodule ({ config, ... }: {
      options = {
        name = mkOption {
          type = str;
          default = config._module.args.name;
          description = "Name of the template";
        };

        vars = mkOption {
          type = attrsOf path;
          description = ''
            Mapping of variable names to files.
            Names must start with a lowercase letter and be valid bash "names."
          '';
          default = { };
        };

        content = mkOption {
          type = str;
          description = ''
            Content of template.
            `$name` will be replaced with the content of file in `vars.name`
          '';
          default = "";
        };

        path = mkOption {
          type = str;
          description = "Path (with filename) to store generated output";
          default = "${cfg.directory}/${config.name}";
        };

        owner = mkOption {
          type = str;
          description = "User to own the output file";
          default = "0";
        };

        group = mkOption {
          type = str;
          description = "Group to own the output file";
          default = "0";
        };

        mode = mkOption {
          type = str;
          description = "Permissions mode for the output file";
          default = "0400";
        };
      };
    });
in
{
  options.roles.template = {
    directory = mkOption {
      type = types.path;
      description = "Default directory to create output files in";
      default = "/run/template";
    };

    files = mkOption {
      type = types.attrsOf fileConfig;
      description = "Templates files to process";
      default = { };
    };
  };

  config =
    let
      inherit (lib) escapeShellArg mapAttrsToList;

      mkScript = name: entry:
        let
          templateName = "template-" + name;
          content = if hasSuffix "\n" entry.content then entry.content else entry.content + "\n";

          eDir = escapeShellArg (dirOf entry.path);
          eOutput = escapeShellArg entry.path;
          eInput = escapeShellArg (pkgs.writeText "${name}.in" content);

          # Only substitute configured variables, others will be ignored.
          allowedVars = escapeShellArg
            (builtins.concatStringsSep " " (map (s: "$" + s) (attrNames entry.vars)));

          setEnvScript = builtins.concatStringsSep "\n"
            (mapAttrsToList
              (var: source: ''export ${var}="$(< ${escapeShellArg source})"'')
              entry.vars);

          # Standalone script to prevent exported secrets leaking.
          activationScript = pkgs.writeShellScript templateName ''
            set -eo pipefail

            mkdir -p ${eDir}
            chmod 701 ${eDir}

            ${setEnvScript}
            ${pkgs.gettext}/bin/envsubst \
              ${allowedVars} \
              < ${eInput} > ${eOutput}

            chmod ${escapeShellArg entry.mode} ${eOutput}
            chown ${escapeShellArg (entry.owner + ":" + entry.group)} ${eOutput}
          '';
        in
        {
          name = templateName;
          value = stringAfter [ "etc" "agenix" ] "${activationScript}";
        };
    in
    mkIf (cfg.files != { }) {
      # Create an output file during activation for each entry in files.
      system.activationScripts = attrsets.mapAttrs' mkScript cfg.files;
    };
}
