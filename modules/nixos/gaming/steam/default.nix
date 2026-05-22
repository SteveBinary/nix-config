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
    programs = {
      steam = {
        enable = true;
        # hidapi is required by Steam's controller firmware updater. Without it
        # Steam logs `ImportError: Unable to load ... libhidapi-hidraw.so` and
        # shows "Failed to update Steam Controller firmware" for the
        # Steam Controller 2026.
        # TODO: remove when library is shipped by Steam itself
        extraPackages = with pkgs; [ hidapi ];
      };
    };
    environment.systemPackages = with pkgs; [
      protonup-qt
    ];
  };
}
