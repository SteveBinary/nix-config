{
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.oh-my-posh;
in
{
  imports = [
    ./bash.nix
    ./zsh.nix
  ];

  options.my.programs.oh-my-posh = {
    enable = lib.mkEnableOption "Enable my Home Manager module for oh-my-posh";
  };

  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      # toggle the environment variable 'SHOW_KUBERNETES_INFO_IN_PROMPT' between 'true' and 'false'
      kk = ''export SHOW_KUBERNETES_INFO_IN_PROMPT=$( [ "$SHOW_KUBERNETES_INFO_IN_PROMPT" = "true" ] && echo "false" || echo "true" )'';
    };

    programs.oh-my-posh = {
      enable = true;
      enableBashIntegration = config.my.programs.shells.bash.enable;
      enableZshIntegration = config.my.programs.shells.zsh.enable;
      settings = {
        version = 2;
        upgrade = {
          notice = false;
          auto = false;
        };
        final_space = true;
        terminal_background = "#1E1E2E";
        palette = {
          red = "#D0164A";
          orange = "#E88243";
          yellow = "#F5DA42";
          green = "#3AD12C";
          blue = "#89B4FA";
          pink = "#F5C2E7";
          lavender = "#B4BEFE";
          error = "p:red";
          os = "#ACB0BE";
          closer = "p:os";
        };
        secondary_prompt = {
          template = " ";
          foreground = "p:closer";
        };
        blocks = [
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "os";
                template = # gotmpl
                  ''{{ if .WSL }}WSL at {{ end }}{{ .Icon }}'';
                style = "plain";
                foreground = "p:os";
              }
              {
                type = "session";
                style = "plain";
                foreground = "p:blue";
              }
              {
                type = "path";
                template = # gotmpl
                  ''{{ if not .Writable }}<p:error> </>{{ end }}{{ .Path }} '';
                style = "plain";
                foreground = "p:pink";
                properties = {
                  style = "full";
                  home_icon = "~";
                };
              }
              {
                type = "git";
                template =
                  builtins.replaceStrings [ "\n" ] [ "" ] # gotmpl
                    ''
                      {{ .UpstreamIcon }} {{ .HEAD }}{{ if .BranchStatus }} {{ .BranchStatus }}{{ end }}
                      {{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}
                      {{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }}  {{ .StashCount }}{{ end }}
                    '';
                style = "plain";
                foreground = "p:lavender";
                properties = {
                  git_icon = " ";
                  branch_icon = " ";
                  cherry_pick_icon = " ";
                  commit_icon = " ";
                  fetch_status = true;
                  fetch_upstream_icon = true;
                  merge_icon = " ";
                  no_commits_icon = " ";
                  rebase_icon = " ";
                  revert_icon = " ";
                  tag_icon = " ";
                };
              }
            ];
          }
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "kubectl";
                template =
                  builtins.replaceStrings [ "\n" ] [ "" ] # gotmpl
                    ''
                      {{ if eq "true" .Env.SHOW_KUBERNETES_INFO_IN_PROMPT }}󱃾 {{ .Context }} @
                      <b>{{ if .Namespace }} {{ .Namespace }}{{ else }} default{{ end }}</b>
                      {{ if      or (regexMatch ".*-prod-?\\d*$" .Namespace) (regexMatch ".*-prod-?\\d*$" .Context) }} <p:red>⬤</>
                      {{ else if or (hasSuffix  "-qa"            .Namespace) (hasSuffix  "-qa"            .Context) }} <p:orange>⬤</>
                      {{ else if or (hasSuffix  "-int"           .Namespace) (hasSuffix  "-int"           .Context) }} <p:yellow>⬤</>
                      {{ else if or (hasSuffix  "-dev"           .Namespace) (hasSuffix  "-dev"           .Context) }} <p:green>⬤</>
                      {{ end }}
                      {{ end }}
                    '';
                style = "plain";
                foreground = "p:blue";
                propterties = {
                  parse_kubeconfig = false;
                };
              }
            ];
          }
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "root";
                style = "plain";
                foreground = "p:error";
              }
              {
                type = "text";
                template = "";
                style = "plain";
                foreground = "p:closer";
              }
            ];
          }
        ];
      };
    };
  };
}
