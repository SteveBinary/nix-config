{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.desktop.plasma-bigscreen;
in
{
  options.my.desktop.plasma-bigscreen = {
    enable = lib.mkEnableOption "Enable my configuration for the KDE Plasma Bigscreen desktop environment";
    autoLoginUser = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager = {
        plasma-login-manager.enable = true;
        autoLogin = {
          enable = true;
          user = cfg.autoLoginUser;
        };
        sessionPackages = [ pkgs.kdePackages.plasma-bigscreen ];
        defaultSession = "plasma-bigscreen-wayland";
      };
    };

    # Plasma Bigscreen depends on KDE Connect
    programs.kdeconnect.enable = true;

    # Disable the personal information management suite (KMail, Kontact, Merkuro)
    programs.kde-pim.enable = false;

    environment.systemPackages = with pkgs; [
      # needed although already set in services.displayManager.sessionPackages
      kdePackages.plasma-bigscreen

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
