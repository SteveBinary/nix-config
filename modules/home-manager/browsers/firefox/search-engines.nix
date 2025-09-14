{ pkgs }:

{
  order = [
    "brave"
    "google"
    "nix-packages"
    "nixos-options"
    "home-manager-options"
    "noogle"
    "nixpkgs-pr-tracker"
    "crates-io"
    "google-maps"
  ];

  engines = {
    "google" = {
      metaData.alias = "@g";
    };
    "brave" = {
      name = "Brave";
      definedAliases = [ "@brave" ];
      urls = [
        {
          template = "https://search.brave.com/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      # https://brave.com/static-assets/images/brave-logo-sans-text.svg
      icon = ./assets/brave-logo-sans-text.svg;
    };
    "nix-packages" = {
      name = "Nix Packages";
      definedAliases = [ "@nix" ];
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    };
    "nixos-options" = {
      name = "NixOS Options";
      definedAliases = [ "@opt" ];
      urls = [
        {
          template = "https://search.nixos.org/options";
          params = [
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    };
    "home-manager-options" = {
      name = "Home Manager Options";
      definedAliases = [ "@opt" ];
      urls = [
        {
          template = "https://home-manager-options.extranix.com";
          params = [
            {
              name = "release";
              value = "master";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    };
    "noogle" = {
      name = "Noogle";
      definedAliases = [ "@noogle" ];
      urls = [
        {
          template = "https://noogle.dev/q";
          params = [
            {
              name = "term";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    };
    "nixpkgs-pr-tracker" = {
      name = "Nixpkgs Pull Request Tracker";
      definedAliases = [ "@nixpr" ];
      urls = [
        {
          template = "https://nixpk.gs/pr-tracker.html";
          params = [
            {
              name = "pr";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    };
    "crates-io" = {
      name = "crates.io";
      definedAliases = [ "@crate" ];
      urls = [
        {
          template = "https://crates.io/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      # https://github.com/rust-lang/crates.io/blob/ec419a5ec314c162d71afc8e18a376080b175c37/public/assets/cargo.png
      icon = ./assets/cargo.png;
    };
    "google-maps" = {
      name = "Google Maps";
      definedAliases = [ "@maps" ];
      urls = [
        {
          template = "https://www.google.com/maps/search/{searchTerms}";
          params = [ ];
        }
      ];
      # https://commons.wikimedia.org/wiki/File:Google_Maps_icon_(2020).svg
      icon = ./assets/Google_Maps_icon_2020.svg;
    };
    bing.metaData.hidden = true;
    ddg.metaData.hidden = true;
    ecosia.metaData.hidden = true;
    wikipedia.metaData.hidden = true;
  };
}
