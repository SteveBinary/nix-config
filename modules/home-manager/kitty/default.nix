{
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.kitty;
in
{
  options.my.programs.kitty = {
    enable = lib.mkEnableOption "Enable my Home Manager module for kitty";
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "MesloLGM Nerd Font";
        size = 13;
      };
      themeFile = "Catppuccin-Mocha";
      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
      };
    };
  };
}
