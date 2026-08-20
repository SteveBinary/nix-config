{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.services.handy;
in
{
  options.my.services.handy = {
    enable = lib.mkEnableOption "Enable my Home Manager module for Handy (offline speech-to-text)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      handy
      xdotool
    ];
  };
}
