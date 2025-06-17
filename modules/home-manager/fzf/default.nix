{
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.fzf;
in
{
  options.my.programs.fzf = {
    enable = lib.mkEnableOption "Enable my Home Manager module for fzf";
  };

  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
