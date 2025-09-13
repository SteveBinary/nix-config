{
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.tools.fzf;
in
{
  options.my.terminal.tools.fzf = {
    enable = lib.mkEnableOption "Enable my Home Manager module for fzf";
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
