{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.ghostty;
in
{
  options.my.terminal.ghostty = {
    enable = lib.mkEnableOption "Enable my Home Manager module for Ghostty";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.meslo-lg
    ];

    programs.ghostty = {
      enable = true;
      settings = {
        font-size = 13;
        font-family = "MesloLGM Nerd Font";
        theme = "Catppuccin Mocha";

        auto-update = "off";

        app-notifications = "no-clipboard-copy";
        bell-features = "no-attention,no-audio,no-border,no-system,no-title";

        maximize = true;
        confirm-close-surface = false;
        quit-after-last-window-closed = false;
        window-decoration = "server";
      };
    };
  };
}
