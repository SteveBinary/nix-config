{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.development.editors.helix;
in
{
  options.my.programs.development.editors.helix = {
    enable = lib.mkEnableOption "Enable Helix";
  };

  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      # this allows 'sudo hx' to use this helix config; the alias sudo="sudo " must also be set
      hx = "hx --config ${config.xdg.configHome}/helix/config.toml";
    };

    home.packages = with pkgs; [
      marksman # markdown
      nil # nix
      taplo # toml
      yaml-language-server # yaml and docker-compose
    ];

    programs.helix = {
      enable = true;
      defaultEditor = true;

      settings = {
        theme = "catppuccin_mocha";

        editor = {
          # show currently open buffers, only when more than one exists
          bufferline = "multiple";
          # color the mode indicator
          color-modes = true;
          # highlight all lines with a cursor
          cursorline = true;
          # use relative line numbers
          line-number = "relative";
          # diable mouse support
          mouse = true;
          # show a ruler at column 150
          rulers = [ 150 ];
          # force truecolor support, currently needed when running in WSL
          true-color = true;
        };

        editor.cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        editor.lsp = {
          display-messages = true;
        };

        editor.statusline = {
          mode.insert = "INSERT";
          mode.normal = "NORMAL";
          mode.select = "SELECT";
          left = [
            "mode"
            "spinner"
          ];
          center = [
            "version-control"
            "file-name"
          ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
        };

        keys.insert = {
          C-left = [ "move_prev_word_start" ]; # faster movement with the arrow keys
          C-right = [ "move_next_word_start" ]; # faster movement with the arrow keys
        };

        keys.normal = {
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ]; # unify what the escape key is doing
          ret = [
            "move_line_down"
            "goto_first_nonwhitespace"
          ]; # move to the start of the next line when pressing enter
          C-left = [
            "move_prev_word_start"
            "move_char_left"
            "move_char_right"
          ]; # faster movement with the arrow keys
          C-right = [
            "move_next_word_start"
            "move_char_left"
            "move_char_right"
          ]; # faster movement with the arrow keys
        };
      };
    };
  };
}
