{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.development.mqtt-explorer;
in
{
  options.my.development.mqtt-explorer = {
    enable = lib.mkEnableOption "Enable my Home Manager module for mqtt-explorer";
    noSandbox = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable (
    let
      patched-mqtt-explorer = pkgs.mqtt-explorer.overrideAttrs (
        finalAttrs: prevAttrs: {
          patches = (prevAttrs.patches or [ ]) ++ [ ./increase_max_value_hight.patch ];
        }
      );
    in
    {
      home.packages = [
        patched-mqtt-explorer
      ]
      ++ lib.optional cfg.noSandbox (
        pkgs.my.lib.patchDesktopFile {
          pkg = patched-mqtt-explorer;
          appName = "mqtt-explorer";
          from = "^Exec=mqtt-explorer";
          to = "Exec=mqtt-explorer --no-sandbox";
        }
      );
    }
  );
}
