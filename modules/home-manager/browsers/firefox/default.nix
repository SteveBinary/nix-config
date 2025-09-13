{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.browsers.firefox;

  searchEngines = import ./search-engines.nix { inherit pkgs; };
in
{
  options.my.browsers.firefox = {
    enable = lib.mkEnableOption "Enable my Home Manager module for Firefox";
    defaultSearchEngine = lib.mkOption {
      type = lib.types.enum searchEngines.order;
      default = "brave";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      languagePacks = [
        "de"
        "en-US"
      ];
      policies = import ./policies.nix;
      profiles.default = {
        id = 0;
        settings = import ./settings.nix;
        search = {
          force = true;
          default = cfg.defaultSearchEngine;
          engines = searchEngines.engines;
          order =
            # the non-default search engines should be listed before the default one
            (lib.lists.remove cfg.defaultSearchEngine searchEngines.order) ++ [
              cfg.defaultSearchEngine
            ];
        };
      };
    };
  };
}
