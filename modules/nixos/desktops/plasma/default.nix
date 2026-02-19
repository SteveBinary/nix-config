{
  pkgs,
  lib,
  config,
  overlays,
  ...
}:

let
  cfg = config.my.desktop.plasma;
in
{
  options.my.desktop.plasma = {
    enable = lib.mkEnableOption "Enable my configuration for the KDE Plasma desktop environment";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      # see: https://github.com/rockowitz/ddcutil/issues/581
      # This overlay should be obsolete once 2.2.6 is available.
      overlays.ddcutil-2-2-3
    ];

    services = {
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = true;
    };

    # Workaround for the long wait time when logging in. Seems to be a bug in SDDM / Plasma Login Manager.
    # see: https://github.com/NixOS/nixpkgs/issues/239770#issuecomment-1868402338
    # This only disables the fingerprint for the login (after a boot or logout).
    # Using the fingerprint to unlock (get back from lock screen) and for sudo is still possible.
    security.pam.services.login.fprintAuth = false;

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      kate
      khelpcenter
    ];

    environment.systemPackages = with pkgs; [
      # mostly for the Info Center app to display all sorts of information
      aha
      clinfo
      mesa-demos
      hdparm
      lshw
      lsscsi
      pciutils
      usbutils
      vulkan-tools
      wayland-utils
    ];
  };
}
