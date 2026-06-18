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
  };

  config = lib.mkIf cfg.enable ({
    home.packages = [
      (pkgs.mqtt-explorer.overrideAttrs (
        finalAttrs: prevAttrs: {
          patches = (prevAttrs.patches or [ ]) ++ [
            ./increase_max_history_height.patch
            ./increase_max_value_height.patch
          ];
        }
      ))
    ];
  });
}
