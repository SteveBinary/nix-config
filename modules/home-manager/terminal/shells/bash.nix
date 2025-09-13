{
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.shells.bash;
in
{
  options.my.terminal.shells.bash = {
    enable = lib.mkEnableOption "Enable my Home Manager module for bash";
    bashrcExtra = lib.mkOption {
      default = "";
      type = lib.types.lines;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [
        "ignoredups"
        "ignorespace"
      ];
      bashrcExtra = lib.concatLines [
        ''
          # if running in Kitty, use the kitten-wrapper for ssh to prevent issues on remote hosts that don't have terminfo for Kitty
          # see: https://wiki.archlinux.org/title/Kitty#Terminal_issues_with_SSH
          [ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"
        ''
        cfg.bashrcExtra
      ];
    };
  };
}
