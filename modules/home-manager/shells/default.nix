{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.shells;
in
{

  imports = [
    ./bash.nix
    ./zsh.nix
    ./oh-my-posh.nix
  ];

  options.my.programs.shells = {
    fancyLS = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    clipboardAliasesBackend = lib.mkOption {
      default = null;
      type = lib.types.nullOr (
        lib.types.enum [
          "Wayland"
          "X11"
        ]
      );
    };
  };

  config = {
    home.packages =
      [ ]
      ++ lib.optional cfg.fancyLS pkgs.lsd
      ++ lib.optional (cfg.clipboardAliasesBackend == "Wayland") pkgs.wl-clipboard
      ++ lib.optional (cfg.clipboardAliasesBackend == "X11") pkgs.xclip;

    home.shellAliases =
      import ./common-shell-aliases.nix
      // lib.optionalAttrs cfg.fancyLS {
        l = "lsd --long --group-directories-first";
        ls = "lsd --long --group-directories-first";
        la = "lsd --all --long --group-directories-first";
        ll = "lsd --all --long --group-directories-first";
      }
      // lib.optionalAttrs (cfg.clipboardAliasesBackend == "Wayland") {
        ccopy = "wl-copy";
        cpaste = "wl-paste";
      }
      // lib.optionalAttrs (cfg.clipboardAliasesBackend == "X11") {
        ccopy = "xclip -in -selection clipboard";
        cpaste = "xclip -out -selection clipboard";
      };
  };
}
