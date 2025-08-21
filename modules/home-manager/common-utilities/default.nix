{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.common-utilities;
in
{
  options.my.programs.common-utilities = {
    enable = lib.mkEnableOption "Enable my commonly used utilities";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      btop
      curl
      delta
      dive
      dnsutils
      dua
      fastfetch
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
      tree
      unzip
      usbutils
      wget
      xh
      yq-go
    ];
  };
}
