{
  pkgs,
  lib,
  config,
  ...
}:

# IMPORTANT:
# Zed is currently designed around the config files being mutable.
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
    package = lib.mkPackageOption pkgs "zed-editor" { };
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
        "catppuccin"
        "catppuccin-icons"
        "nix"
        "toml"
        "typst"
      ];

      #############################################################################################
      # settings                                                                                  #
      #############################################################################################

      userSettings = {
        auto_update = false;
        base_keymap = "JetBrains";
        hour_format = "hour24";
        load_direnv = "shell_hook";
        default_open_behavior = "new_window";

        autosave = "on_focus_change";
        format_on_save = "off";
        formatter = "none";
        buffer_font_family = "FiraCode Nerd Font";
        scroll_beyond_last_line = "vertical_scroll_margin";
        mouse_wheel_zoom = true;

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

        edit_predictions = {
          allow_data_collection = "no";
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

        git = {
          hunk_style = "unstaged_hollow";
          inline_blame.enabled = false;
        };

        title_bar = {
          show_sign_in = false;
        };
        outline_panel = {
          dock = "left";
          indent_size = 15.0;
        };
        agent = {
          dock = "right";
          sidebar_side = "right";
        };
        collaboration_panel = {
          dock = "left";
          button = false;
        };
        git_panel = {
          dock = "left";
          entry_primary_click_action = "file_diff";
          status_style = "label_color";
          file_icons = true;
          tree_view = true;
        };
        project_panel = {
          dock = "left";
          indent_size = 15.0;
        };
      }
      // lib.optionalAttrs (cfg.fontSizes.ui != null) {
        ui_font_size = cfg.fontSizes.ui;
      }
      // lib.optionalAttrs (cfg.fontSizes.editor != null) {
        buffer_font_size = cfg.fontSizes.editor;
      }

      #############################################################################################
      # language support                                                                          #
      #############################################################################################

      // {
        languages = {
          Nix = {
            language_servers = [
              "nixd"
              "!nil"
            ];
            formatter = {
              external = {
                command = "nixfmt";
                arguments = [
                  "--quiet"
                  "-"
                ];
              };
            };
          };
          Typst = {
            formatter = {
              external = {
                command = "typstyle";
              };
            };
          };
        };
        lsp = {
          nixd = {
            binary.path_lookup = true;
          };
          tinymist = {
            initialization_options = {
              # enable background preview, open browser at 127.0.0.1:23635 to see the live preview
              preview.background.enabled = false;
            };
            settings = {
              # compile the PDF on save for the `main.typ` file in the project root
              exportPdf = "onSave";
              outputPath = "$root/target/$dir/$name";
            };
          };
        };
      };

      extraPackages = with pkgs; [
        # formatters
        nixfmt
        typstyle

        # language servers
        nixd
        tinymist
      ];
    };
  };
}
