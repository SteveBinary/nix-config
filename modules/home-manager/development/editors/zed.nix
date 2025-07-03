{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.development.editors.zed;
in
{
  options.my.programs.development.editors.zed = {
    enable = lib.mkEnableOption "Enable Zed";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zed-editor;
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
        terminal.font_family = "MesloLGM Nerd Font";
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
