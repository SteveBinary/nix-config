{
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.tools.zellij;
in
{
  options.my.terminal.tools.zellij = {
    enable = lib.mkEnableOption "Enable my Home Manager module for zellij";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      settings = {
        theme = "catppuccin-mocha";
      };
    };
  };
}
