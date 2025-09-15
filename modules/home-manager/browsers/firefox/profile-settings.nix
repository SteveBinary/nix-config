{ lib, cfg }:

{
  "browser.newtabpage.activity-stream.showSponsored" = false;
  "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
  "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
  "browser.newtabpage.activity-stream.discoverystream.enabled" = false;

  "browser.translations.enable" = true;
  "browser.translations.panelShown" = true;
  "browser.translations.neverTranslateLanguages" = "de,en";

  "browser.urlbar.showSearchSuggestionsFirst" = false;
  "browser.urlbar.suggest.engines" = false;
  "browser.urlbar.suggest.topsites" = false;
  "browser.urlbar.suggest.trending" = false;
  "browser.urlbar.suggest.quickactions" = false;
  "browser.urlbar.shortcuts.actions" = false;
  "browser.urlbar.shortcuts.bookmarks" = false;
  "browser.urlbar.shortcuts.history" = false;
  "browser.urlbar.shortcuts.tabs" = false;

  "devtools.toolbox.host" = "right";

  "extensions.pocket.enabled" = false;
  "extensions.htmlaboutaddons.recommendations.enabled" = false;

  "intl.accept_languages" = "de,en";

  "network.protocol-handler.external.mailto" = false;

  "signon.management.page.breach-alerts.enabled" = false;

  "widget.use-xdg-desktop-portal.file-picker" = 1;

  # Disable some telemetry
  "app.shield.optoutstudies.enabled" = false;
  "browser.discovery.enabled" = false;
  "browser.newtabpage.activity-stream.feeds.telemetry" = false;
  "browser.newtabpage.activity-stream.telemetry" = false;
  "browser.ping-centre.telemetry" = false;
  "datareporting.healthreport.service.enabled" = false;
  "datareporting.healthreport.uploadEnabled" = false;
  "datareporting.policy.dataSubmissionEnabled" = false;
  "datareporting.sessions.current.clean" = true;
  "devtools.onboarding.telemetry.logged" = false;
  "toolkit.telemetry.archive.enabled" = false;
  "toolkit.telemetry.bhrPing.enabled" = false;
  "toolkit.telemetry.enabled" = false;
  "toolkit.telemetry.firstShutdownPing.enabled" = false;
  "toolkit.telemetry.hybridContent.enabled" = false;
  "toolkit.telemetry.newProfilePing.enabled" = false;
  "toolkit.telemetry.prompted" = 2;
  "toolkit.telemetry.rejected" = true;
  "toolkit.telemetry.reportingpolicy.firstRun" = false;
  "toolkit.telemetry.server" = "";
  "toolkit.telemetry.shutdownPingSender.enabled" = false;
  "toolkit.telemetry.unified" = false;
  "toolkit.telemetry.unifiedIsOptIn" = false;
  "toolkit.telemetry.updatePing.enabled" = false;
}
// lib.optionalAttrs (cfg.theme == "system") {
  "browser.theme.toolbar-theme" = 2;
  "browser.theme.content-theme" = 2;
  "extensions.activeThemeID" = "default-theme@mozilla.org";
  "layout.css.prefers-color-scheme.content-override" = 2;
}
// lib.optionalAttrs (cfg.theme == "light") {
  "browser.theme.toolbar-theme" = 1;
  "browser.theme.content-theme" = 1;
  "extensions.activeThemeID" = "firefox-compact-light@mozilla.org";
  "layout.css.prefers-color-scheme.content-override" = 1;
}
// lib.optionalAttrs (cfg.theme == "dark") {
  "browser.theme.toolbar-theme" = 0;
  "browser.theme.content-theme" = 0;
  "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
  "layout.css.prefers-color-scheme.content-override" = 0;
}
// lib.optionalAttrs cfg.extensions.sideberry.enable {
  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
}
