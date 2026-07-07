{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.tools.btop;
in
{
  options.my.terminal.tools.btop = {
    enable = lib.mkEnableOption "Enable my Home Manager module for btop";
    package = lib.mkPackageOption pkgs "btop" { };
  };

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
      package = cfg.package;
      settings = {
        color_theme = "catppuccin_mocha";
        update_ms = 500;
        shown_boxes = "cpu mem net proc gpu0";
        show_uptime = false;
        clock_format = " %X | %A, %d. %B %Y | /user@/host | uptime = /uptime ";
      };
      themes = {
        # https://github.com/catppuccin/btop/blob/f437574b600f1c6d932627050b15ff5153b58fa3/themes/catppuccin_mocha.theme
        catppuccin_mocha = ./catppuccin_mocha.theme;
      };
    };
  };
}
