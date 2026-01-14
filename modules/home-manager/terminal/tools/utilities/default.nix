{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.tools.utilities;
in
{
  options.my.terminal.tools.utilities = {
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
  };
}
