{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.utilities;
in
{
  options.my.programs.utilities = {
    enable = lib.mkEnableOption "Enable my common utilities";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      delta
      dive
      dnsutils
      fastfetch
      file
      hexyl
      jq
      parallel
      ripgrep
      tldr
      tree
      yq-go
    ];

    programs.jqp = {
      enable = true;
      settings = {
        theme.name = "catppuccin-mocha";
      };
    };
  };
}
