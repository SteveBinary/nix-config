{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.services.kde-connect;
in
{
  options.my.services.kde-connect = {
    enable = lib.mkEnableOption "Enable my Home Manager module for kde-connect";
  };

  config = lib.mkIf cfg.enable {
    services.kdeconnect = {
      enable = true;
      package = pkgs.kdePackages.kdeconnect-kde;
    };
  };
}
