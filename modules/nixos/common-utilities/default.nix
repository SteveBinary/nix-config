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
      delta
      dive
      dnsutils
      dua
      fastfetch
      fd
      file
      hexyl
      hyperfine
      iw
      jq
      killall
      lshw
      lsscsi
      mtr
      parallel
      pciutils
      ripgrep
      tldr
      tokei
      tree
      unzip
      usbutils
      wget
      xh
      yq-go
    ];

    programs.trippy.enable = true;
  };
}
