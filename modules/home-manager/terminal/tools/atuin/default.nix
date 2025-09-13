{
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.tools.atuin;
in
{
  options.my.terminal.tools.atuin = {
    enable = lib.mkEnableOption "Enable my Home Manager module for Atuin";
  };

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        # behavior
        update_check = false;
        enter_accept = true;
        command_chaining = true;
        history_format = "{time}\t{duration}\t{command}";
        # looks
        style = "full";
        inline_height = 9;
        max_preview_height = 3;
        show_preview = true;
        show_help = false;
        show_tabs = false;
        prefers_reduced_motion = true;
        theme.name = "catppuccin-mocha-blue";
      };
      themes = {
        # https://github.com/catppuccin/atuin/blob/abfab12de743aa73cf20ac3fa61e450c4d96380c/themes/mocha/catppuccin-mocha-blue.toml
        catppuccin-mocha-blue = {
          theme.name = "Catppuccin Mocha (Blue)";
          colors = {
            AlertInfo = "#a6e3a1";
            AlertWarn = "#fab387";
            AlertError = "#f38ba8";
            Annotation = "#89b4fa";
            Base = "#cdd6f4";
            Guidance = "#9399b2";
            Important = "#f38ba8";
            Title = "#89b4fa";
          };
        };
      };
    };
  };
}
