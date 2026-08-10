{
  config,
  lib,
  pkgs,
  ...
}:

# TODO: this module may be obsolete when https://github.com/NixOS/nixpkgs/pull/495396 arrives

let
  cfg = config.my.hardware.probe-rs-tools;
in
{
  options.my.hardware.probe-rs-tools = {
    enable = lib.mkEnableOption "probe-rs-tools with udev rules applied";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.probe-rs-tools ];
    services.udev.packages = [ pkgs.probe-rs-tools ];

    users.groups.plugdev = { };
  };
}
