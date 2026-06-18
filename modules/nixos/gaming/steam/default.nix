{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.gaming.steam;
in
{
  options.my.gaming.steam = {
    enable = lib.mkEnableOption "Enable my configuration for Steam";
  };

  config = lib.mkIf cfg.enable {
    hardware.steam-hardware.enable = true;
    programs.steam.enable = true;
    environment.systemPackages = with pkgs; [
      protonup-qt
    ];
  };
}
