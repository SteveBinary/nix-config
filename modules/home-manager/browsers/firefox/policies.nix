{ lib, cfg }:

# https://mozilla.github.io/policy-templates/

let
  mkOptionalExtensionPolicy =
    enabled: id: settings:
    lib.optionalAttrs enabled {
      "${id}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
        installation_mode = "force_installed";
      }
      // settings;
    };
in
{
  DisableTelemetry = true;
  DisableFirefoxStudies = true;
  DisablePocket = true;
  DisableAccounts = true;
  DisableFirefoxAccounts = true;
  EnableTrackingProtection = {
    Locked = true;
    Value = true;
    Category = "strict";
  };

  AutofillAddressEnabled = false;
  AutofillCreditCardEnabled = false;
  OfferToSaveLogins = false;

  DisableAppUpdate = true;
  DontCheckDefaultBrowser = true;
  DisableSetDesktopBackground = true;
  DisplayBookmarksToolbar = "always";

  UserMessaging = {
    ExtensionRecommendations = false;
    FeatureRecommendations = false;
    SkipOnboarding = true;
    MoreFromMozilla = false;
    FirefoxLabs = false;
  };

  Homepage = {
    StartPage = "previous-session";
  };

  FirefoxHome = {
    Locked = true;
    Search = true;
    TopSites = false;
    SponsoredTopSites = false;
    Highlights = false;
    Stories = false;
    SponsoredStories = false;
  };

  # https://mozilla.github.io/policy-templates/#extensionsettings
  #
  # to get the extension IDs:
  #   - if not already done, set extensions.allowManualInstallation to true
  #   - install the desired extension manually from the add-on store
  #   - grab the extension ID from about:support#addons
  #   - uninstall the desired extension
  #   - unset extensions.allowManualInstallation if it was set before
  ExtensionSettings = lib.mergeAttrsList [
    (lib.optionalAttrs (!cfg.extensions.allowManualInstallation) {
      # block all other extensions
      "*".installation_mode = "blocked";
    })
    (mkOptionalExtensionPolicy cfg.extensions.bitwarden.enable "{446900e4-71c2-419f-a6a7-df9c091e268b}"
      {
        default_area = "navbar";
        private_browsing = true;
      }
    )
    (mkOptionalExtensionPolicy cfg.extensions.plasmaBrowserIntegration.enable
      "plasma-browser-integration@kde.org"
      {
        default_area = "menupanel";
        private_browsing = false;
      }
    )
    (mkOptionalExtensionPolicy cfg.extensions.sideberry.enable "{3c078156-979c-498b-8990-85f7987dd929}"
      {
        default_area = "menupanel";
        private_browsing = true;
      }
    )
    (mkOptionalExtensionPolicy cfg.extensions.uBlockOrigin.enable "uBlock0@raymondhill.net" {
      default_area = "menupanel";
      private_browsing = true;
    })
  ];
}
