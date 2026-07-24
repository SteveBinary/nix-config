{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.browsers.chromium;
in
{
  options.my.browsers.chromium = {
    enable = lib.mkEnableOption "Enable my Home Manager module for Chromium";
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };
  };
}
