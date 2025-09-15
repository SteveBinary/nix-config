{
  pkgs,
  lib,
  config,
  ...
}:

# IMPORTANT:
# Zen is currently designed around the config files being mutable.
# Home Manager has implemented a mechanism to merge the current config files with the generated one.
# It copies the merged files back into the expected location (~/.config/zed/...).
# In order to make these files writable by Zed, they are not a symlink into the nix store.
# -> There is no 100% determinism possible.
# -> To reset the changes and remove all side effects, delete the respective files and do a switch.
# see: https://github.com/zed-industries/zed/issues/24537#issuecomment-2784496147
# see: https://github.com/nix-community/home-manager/issues/6835

let
  cfg = config.my.development.editors.zed;
in
{
  options.my.development.editors.zed = {
    enable = lib.mkEnableOption "Enable Zed";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zed-editor;
    };
    fontSizes = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options = {
          ui = lib.mkOption {
            default = null;
            type = lib.types.nullOr lib.types.ints.positive;
          };
          editor = lib.mkOption {
            default = null;
            type = lib.types.nullOr lib.types.ints.positive;
          };
          terminal = lib.mkOption {
            default = null;
            type = lib.types.nullOr lib.types.ints.positive;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = cfg.package;
      extensions = [
        "asciidoc"
        "basher"
        "catppuccin"
        "catppuccin-icons"
        "docker-compose"
        "dockerfile"
        "gleam"
        "groovy"
        "helm"
        "html"
        "java"
        "javascript"
        "json"
        "kotlin"
        "nginx"
        "nix"
        "toml"
        "typst"
      ];
      userSettings = {
        auto_update = false;
        base_keymap = "JetBrains";
        format_on_safe = "off";
        formatter = "language_server";
        hour_format = "hour24";
        load_direnv = "shell_hook";
        buffer_font_family = "FiraCode Nerd Font";
        terminal = {
          font_family = "MesloLGM Nerd Font";
        }
        // lib.optionalAttrs (cfg.fontSizes.terminal != null) {
          font_size = cfg.fontSizes.terminal;
        };
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        theme = {
          mode = "dark";
          light = "Catppuccin Latte";
          dark = "Catppuccin Mocha";
        };
        icon_theme = {
          mode = "dark";
          light = "Catppuccin Latte";
          dark = "Catppuccin Mocha";
        };
      }
      // lib.optionalAttrs (cfg.fontSizes.ui != null) {
        ui_font_size = cfg.fontSizes.ui;
      }
      // lib.optionalAttrs (cfg.fontSizes.editor != null) {
        buffer_font_size = cfg.fontSizes.editor;
      };
      extraPackages = with pkgs; [
        bash-language-server # Bash
        helm-ls # Helm
        jdt-language-server # Java
        kotlin-language-server # Kotlin
        nginx-language-server # nginx
        nixd # Nix
        python313Packages.python-lsp-server # Python
        rust-analyzer # Rust
        shellcheck # shell script analysis
        taplo # TOML
        tinymist # Typst (language server)
        typescript-language-server # JavaScript, TypeScript
        typst # Typst
        yaml-language-server # YAML
      ];
    };
  };
}
