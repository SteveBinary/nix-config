{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.shells.zsh;
  autostart_zellij_when_running_in = [
    "kitty"
    "konsole"
  ];
  concat_process_names =
    separator: builtins.concatStringsSep separator (map (p: "'${p}'") autostart_zellij_when_running_in);
in
{
  options.my.programs.shells.zsh = {
    enable = lib.mkEnableOption "Enable my Home Manager module for zsh";
    zshrcExtra = lib.mkOption {
      default = "";
      type = lib.types.lines;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autocd = true;
      autosuggestion.enable = true;
      dotDir = ".config/zsh";
      history = {
        size = 5000;
        save = 5000;
        ignoreDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        share = true;
      };
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "brackets"
          "pattern"
        ];
        patterns = {
          "rm -rf" = "fg=white,bold,bg=red";
          "sudo " = "fg=green,bold";
        };
      };
      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
      ];
      initContent = lib.mkMerge [
        (lib.mkBefore ''
          # colors for the default completion menu
          zstyle ':completion:*' list-colors "$${(s.:.)LS_COLORS}"
        '')
        ''
          # extras for history
          HISTDUP=erase
          setopt APPEND_HISTORY
          setopt SHARE_HISTORY
          setopt HIST_SAVE_NO_DUPS
          setopt HIST_FIND_NO_DUPS

          # replace the default completion menu by fzf
          zstyle ':completion:*' menu no
          zstyle ':fzf-tab:complete:*' fzf-preview 'ls --color $realpath'
        ''
        (lib.optionalString config.my.programs.kitty.enable ''
          # if running in Kitty, use the kitten-wrapper for ssh to prevent issues on remote hosts that don't have terminfo for Kitty
          # see: https://wiki.archlinux.org/title/Kitty#Terminal_issues_with_SSH
          # BUT: don't set the alias in Zellij because of https://github.com/zellij-org/zellij/issues/4093
          [ -z "$ZELLIJ" ] && [ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"
        '')
        (lib.optionalString config.my.programs.development.kubernetes.enable ''
          # fix that the kubecolor tab-completions are not working when the kubectl completions are not triggered at least once before
          compdef kubecolor=kubectl
        '')
        (lib.optionalString (config.programs.zellij.enable && !config.programs.zellij.enableZshIntegration)
          ''
            # autostart zellij when running via ${concat_process_names ", "}
            parent_process_names_that_trigger_zellij_autostart=(${concat_process_names " "})
            current_parent_process_name="$(basename "/"$(ps -o cmd -f -p $(cat /proc/$(echo $$)/stat | cut -d ' ' -f 4) | tail -1 | sed 's/ .*$//'))"
            if (($parent_process_names_that_trigger_zellij_autostart[(Ie)$current_parent_process_name])); then
              eval "$(zellij setup --generate-auto-start zsh)"
            fi
            unset current_parent_process_name
            unset parent_process_names_that_trigger_zellij_autostart
          ''
        )
        cfg.zshrcExtra
      ];
    };
  };
}
