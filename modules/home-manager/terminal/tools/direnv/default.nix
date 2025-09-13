{
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.tools.direnv;
in
{
  options.my.terminal.tools.direnv = {
    enable = lib.mkEnableOption "Enable my Home Manager module for direnv";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      config.global.warn_timeout = "1h"; # https://github.com/direnv/direnv/blob/master/man/direnv.toml.1.md
    };

    home.sessionVariables = {
      DIRENV_LOG_FORMAT = "";
    };
  };
}
