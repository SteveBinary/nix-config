{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.my.programs.kitty;
in
{
  options.my.programs.kitty = {
    enable = lib.mkEnableOption "Enable my Home Manager module for kitty";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kitty;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      package = cfg.package;
      font = {
        name = "MesloLGM Nerd Font";
        package = pkgs.nerd-fonts.meslo-lg;
        size = 13;
      };
      themeFile = "Catppuccin-Mocha";
      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
      settings = {
        confirm_os_window_close = 0;
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
      };
    };
  };
}
