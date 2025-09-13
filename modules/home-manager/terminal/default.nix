{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.terminal;
in
{
  imports = [
    ./kitty
    ./shells
    ./tools
  ];

  options.my.terminal = {
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

    home.shellAliases = {
      c = "clear";
      n = "cd ~/nix-config";
      p = "cd ~/Projects";
      reboot-now = "sudo shutdown -r now";
      sudo = "sudo "; # for shell aliases to be usable with sudo
    }
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
