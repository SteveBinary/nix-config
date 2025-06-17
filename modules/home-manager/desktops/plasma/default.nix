{
  pkgs,
  lib,
  config,
  ...
}:

##### Getting the app IDs
# Run   'ls /run/current-system/sw/share/applications'         for programs installed via the system config.
# Run   'ls /etc/profiles/per-user/steve/share/applications'   for programs installed via Home Manager.
# Run   'ls /run/current-system/sw/share/plasma/plasmoids'     for the plasmoids.
# There is more in '/run/current-system/sw/share/plasma'.
# One can also just apply configs via the UI and look for the changes in the config files under ~/.config

let
  cfg = config.my.desktops.plasma;
in
{
  options.my.desktops.plasma = {
    enable = lib.mkEnableOption "Enable my Home Manager module for KDE Plasma";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kdePackages.kcolorchooser
      kdePackages.kdepim-addons
      kdePackages.ksystemlog
    ];

    programs.plasma = {
      enable = true;
      overrideConfig = true;
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        theme = "breeze-dark";
      };
      fonts.fixedWidth = {
        family = "FiraCode Nerd Font";
        pointSize = 10;
      };
      krunner.position = "center";
      kwin.effects.shakeCursor.enable = false;
      shortcuts =
        {
          "kwin"."Window Maximize" = "Meta+Up";
          "kwin"."ClearLastMouseMark" = "Ctrl+Shift+F12";
          "kwin"."ClearMouseMarks" = "Ctrl+Shift+F11";
          "services/org.kde.kcolorchooser.desktop"."_launch" = "Meta+Shift+C";
          "services/org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Meta+Shift+S";
        }
        // lib.optionalAttrs config.my.programs.kitty.enable {
          "services/kitty.desktop"."_launch" = "Ctrl+Alt+T";
        };
      configFile = {
        baloofilerc = {
          General = {
            "only basic indexing" = true;
            "exclude folders" = {
              value = "$HOME/Projects/";
              shellExpand = true;
            };
          };
        };
        dolphinrc = {
          General = {
            GlobalViewProps = false;
          };
          VersionControl = {
            enabledPlugins = "Git";
          };
        };
        kdeglobals = {
          General = lib.optionalAttrs config.my.programs.kitty.enable {
            TerminalApplication = "kitty";
            TerminalService = "kitty.desktop";
          };
          KDE = {
            AnimationDurationFactor = 0.25;
          };
        };
        krunnerrc = {
          Plugins = {
            browserhistoryEnabled = false;
            browsertabsEnabled = false;
            krunner_appstreamEnabled = false;
            krunner_katesessionsEnabled = false;
            krunner_konsoleprofilesEnabled = false;
          };
        };
        kwinrc = {
          Plugins = {
            mousemarkEnabled = true;
          };
          Effect-mousemark = {
            Freedrawalt = false;
            Freedrawcontrol = true;
            Freedrawshift = true;
            Freedrawmeta = false;
            Arrowdrawalt = false;
            Arrowdrawcontrol = true;
            Arrowdrawshift = true;
            Arrowdrawmeta = true;
          };
          Effect-overview = {
            BorderActivate = 9;
          };
        };
      };
      input.touchpads = [
        {
          enable = true;
          name = "PIXA3854:00 093A:0274 Touchpad";
          vendorId = "093a";
          productId = "0274";
          tapToClick = true;
          disableWhileTyping = false;
          middleButtonEmulation = false;
          naturalScroll = true;
          pointerSpeed = 0.6;
          accelerationProfile = "none";
        }
      ];
      panels = [
        {
          screen = "all";
          location = "bottom";
          floating = true;
          widgets = [
            {
              kickoff = {
                icon = "nix-snowflake-white";
              };
            }
            {
              iconTasks.launchers = [
                "applications:firefox.desktop"
                "applications:thunderbird.desktop"
                "applications:org.kde.dolphin.desktop"
              ];
            }
            "org.kde.plasma.marginsseparator"
            {
              systemTray.items = {
                shown = [
                  "org.kde.plasma.volume"
                  "org.kde.plasma.microphone"
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.battery"
                ];
                hidden = [
                  "org.kde.plasma.bluetooth"
                  "org.kde.plasma.brightness"
                  "org.kde.plasma.clipboard"
                  "Nextcloud"
                  "Proton"
                ];
              };
            }
            {
              digitalClock = {
                calendar.firstDayOfWeek = "monday";
                date.format.custom = "dd.MM.yyyy";
                time.format = "24h";
              };
            }
            "org.kde.plasma.showdesktop"
          ];
        }
      ];
    };
  };
}
