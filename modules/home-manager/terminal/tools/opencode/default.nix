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
      tui = {
        # https://github.com/catppuccin/opencode/blob/d5f409632e6294762925fae869ad0c96dc17cd8e/themes/mocha/catppuccin-mocha-blue.json
        theme = "catppuccin-mocha-blue";
      };
      settings = pkgs.my.lib.merge.deepMergeAll [
        {
          autoupdate = false;
          share = "disabled";

          agent = pkgs.my.lib.importDirectoryRecursivelyIntoAttrset ./agents;
          default_agent = "plan";

          enabled_providers = cfg.providers;
        }
        (lib.optionalAttrs (lib.elem "nexus" cfg.providers) {
          plugin = [
            # To update this custom provider:
            #   1. Update the git repo.
            #   2. run:
            #     - bun install
            #     - bun run build
            "file://${config.home.homeDirectory}/Projects/tmp/opencode-nexus-provider/dist/index.js"
          ];
        })
      ];
    };
  };
}
