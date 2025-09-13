{
  lib,
  config,
  ...
}:

let
  cfg = config.my.services.nextcloud-client;
in
{
  options.my.services.nextcloud-client = {
    enable = lib.mkEnableOption "Enable my Home Manager module for nextcloud-client";
  };

  config = lib.mkIf cfg.enable {
    services.nextcloud-client.enable = true;
  };
}
