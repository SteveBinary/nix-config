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
  imports = [
    ./apparmor-ubuntu.nix
  ];

  options.my.browsers.firefox = {
    enable = lib.mkEnableOption "Enable my Home Manager module for Firefox";
    defaultSearchEngine = lib.mkOption {
      type = lib.types.enum searchEngines.order;
      default = "brave";
    };
    theme = lib.mkOption {
      type = lib.types.enum [
        "system"
        "light"
        "dark"
      ];
      default = "system";
    };
    extensions = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options = {
          allowManualInstallation = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          bitwarden = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "Enable the Bitwarden Firefox extension";
              };
            };
          };
          plasmaBrowserIntegration = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "Enable the Plasma Browser Integration Firefox extension";
                nativeMessagingHostPackage = lib.mkOption {
                  default = pkgs.kdePackages.plasma-browser-integration;
                  type = lib.types.package;
                };
              };
            };
          };
          reactDeveloperTools = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "Enable the React Developer Tools Firefox extension";
              };
            };
          };
          sidebery = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "Enable the Sidebery Firefox extension";
              };
            };
          };
          uBlockOrigin = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "Enable the uBlock Origin Firefox extension";
              };
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      languagePacks = [
        "de"
        "en-US"
      ];
      nativeMessagingHosts = lib.optional cfg.extensions.plasmaBrowserIntegration.enable cfg.extensions.plasmaBrowserIntegration.nativeMessagingHostPackage;
      policies = import ./policies.nix { inherit lib cfg; };
      profiles.default = {
        id = 0;
        settings = import ./profile-settings.nix { inherit lib cfg; };
        userChrome = lib.mkIf cfg.extensions.sidebery.enable (
          lib.strings.concatLines [
            (
              # https://github.com/MrOtherGuy/firefox-csshacks/blob/55cdb2938da52407aeff7093c979dafb7782e7c9/chrome/hide_tabs_toolbar_v2.css
              builtins.readFile ./assets/hide_tabs_toolbar_v2.css
            )
            ''
              /* --- my own additions --- */

              /* hide the header in the sidebar - remove the dropdown menu and close button */
              #sidebar-header {
                display: none;
              }
            ''
          ]
        );
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
