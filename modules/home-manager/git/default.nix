{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.git;
in
{
  options.my.programs.git = {
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
      userName = cfg.userName;
      userEmail = cfg.userEmail;
      includes = cfg.includes;
      extraConfig = {
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
