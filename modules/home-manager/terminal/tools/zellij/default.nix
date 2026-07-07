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
    home = {
      sessionVariables = {
        # There is a guard around zellij's auto-start in the ZSH config, so that zellij auto-starts only in certain terminals and never in an SSH session.
        # When when the conditions for auto-start are matched, these variables will be respected.
        ZELLIJ_AUTO_ATTACH = "true";
        ZELLIJ_AUTO_EXIT = "true";
      };
      shellAliases = {
        z = "zellij";
      };
    };

    programs.zellij = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      settings = {
        theme = "catppuccin-mocha";
        show_startup_tips = false;
      };
    };
  };
}
