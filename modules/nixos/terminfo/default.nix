{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminfo;
in
{
  options.my.terminfo = {
    enableGhostty = lib.mkEnableOption "Enable Ghostty terminfo";
  };

  config = {
    environment.systemPackages = lib.optional cfg.enableGhostty pkgs.ghostty.terminfo;
  };
}
