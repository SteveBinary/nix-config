{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.common-utilities;
in
{
  options.my.common-utilities = {
    enable = lib.mkEnableOption "Enable my commonly used utilities";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      btop
      curl
      iw
      killall
      mtr
      ncdu
      trash-cli
      unzip
      wget
    ];
  };
}
