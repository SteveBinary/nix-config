{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal.tools.git;
in
{
  options.my.terminal.tools.git = {
    enable = lib.mkEnableOption "Enable my Home Manager module for git";
    userName = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
    userEmail = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
    askpass = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
    };
    includes = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.anything;
    };
  };

  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      gs = "git status";
    };

    programs.git = {
      enable = true;
      includes = cfg.includes;
      settings = {
        user = {
          name = lib.mkIf (cfg.userName != null) cfg.userName;
          email = lib.mkIf (cfg.userEmail != null) cfg.userEmail;
        };
        alias = {
          l = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
        };
        core.askpass = lib.mkIf (cfg.askpass != null) cfg.askpass;
        init.defaultbranch = "main";
        push.autoSetupRemote = true;

        # diff syntax highlighting with delta
        core.pager = "${pkgs.delta}/bin/delta";
        interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
        merge.conflictstyle = "zdiff3";
        delta = {
          syntax-theme = "catppuccin-mocha"; # Delta themes come from bat. And the "catppuccin-mocha" theme is a custom bat theme, defined in my nix config.
          hyperlinks = true;
          line-numbers = true;
          navigate = true;
          side-by-side = true;
          features = "decorations";
          decorations = {
            file-decoration-style = "blue ol";
            hunk-header-style = "omit";
          };
        };
      };
    };
  };
}
