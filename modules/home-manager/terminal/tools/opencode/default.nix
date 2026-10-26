{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.tools.opencode;
in
{
  options.my.terminal.tools.opencode = {
    enable = lib.mkEnableOption "Enable my Home Manager module for OpenCode";
    providers = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      themes = ./themes;
      cli = {
        # https://github.com/catppuccin/opencode/blob/d5f409632e6294762925fae869ad0c96dc17cd8e/themes/mocha/catppuccin-mocha-blue.json
        theme.name = "catppuccin-mocha-blue";
        attention.notifications = false;
        attention.sound = false;
        highlights = false;
        terminal.title = false;
      };
      settings = pkgs.my.lib.merge.deepMergeAll [
        {
          update = "disable";

          agents = pkgs.my.lib.importDirectoryRecursivelyIntoAttrset ./agents;
          default_agent = "plan";

          permissions = [
            {
              action = "external_directory";
              resource = "*";
              effect = "ask";
            }
            {
              action = "read";
              resource = "*.env";
              effect = "deny";
            }
            {
              action = "read";
              resource = "*.env.*";
              effect = "deny";
            }
            {
              action = "read";
              resource = "*/.ssh/*";
              effect = "deny";
            }
            {
              action = "read";
              resource = "*/.gnupg/*";
              effect = "deny";
            }
            {
              action = "read";
              resource = "*/.aws/*";
              effect = "deny";
            }
            {
              action = "read";
              resource = "*/.kube/*";
              effect = "deny";
            }
          ];

          policies = [
            {
              action = "provider.use";
              resource = "*";
              effect = "deny";
            }
          ]
          ++ lib.map (provider: {
            action = "provider.use";
            resource = provider;
            effect = "allow";
          }) cfg.providers;
        }
        (lib.optionalAttrs (lib.elem "nexus" cfg.providers) {
          plugins = [
            # To update this custom provider:
            #   1. Update the git repo.
            #   2. run:
            #     - bun install
            #     - bun run build
            "file://${config.home.homeDirectory}/Projects/tmp/opencode-nexus-provider/dist"
          ];
        })
      ];
    };
  };
}
