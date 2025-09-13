{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.tools.bat;
in
{
  options.my.terminal.tools.bat = {
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
            rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
            sha256 = "lJapSgRVENTrbmpVyn+UQabC9fpV1G1e+CdlJ090uvg=";
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
