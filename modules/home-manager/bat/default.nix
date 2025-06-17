{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.bat;
in
{
  options.my.programs.bat = {
    enable = lib.mkEnableOption "Enable my Home Manager module for bat";
  };

  config = lib.mkIf cfg.enable {
    programs.bat = {
      enable = true;
      themes = {
        catppuccin-mocha = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "d714cc1d358ea51bfc02550dabab693f70cccea0";
            sha256 = "Q5B4NDrfCIK3UAMs94vdXnR42k4AXCqZz6sRn8bzmf4=";
          };
          file = "themes/Catppuccin Mocha.tmTheme";
        };
      };
    };

    home.shellAliases = {
      cat = "bat";
    };

    home.sessionVariables = {
      BAT_THEME = "catppuccin-mocha";

      # workaround so that bat prints Unicode characters correctly, see: https://github.com/sharkdp/bat/issues/2578
      LESSUTFCHARDEF = "E000-F8FF:p,F0000-FFFFD:p,100000-10FFFD:p";
    };
  };
}
