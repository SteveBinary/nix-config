{
  lib,
  config,
  ...
}:

let
  cfg = config.my.localization;
in
{
  options.my.localization = {
    language = lib.mkOption {
      default = null;
      type = lib.types.nullOr (
        lib.types.enum [
          "de"
          "en_de"
        ]
      );
    };
    timeZone = lib.mkOption {
      default = "Europe/Berlin";
      type = lib.types.str;
    };
  };

  config = lib.mkMerge [
    {
      time.timeZone = cfg.timeZone;
    }
    (lib.mkIf (cfg.language == "de") {
      services.xserver.xkb.layout = "de";
      console.keyMap = "de";
      i18n.defaultLocale = "de_DE.UTF-8";
    })
    (lib.mkIf (cfg.language == "en_de") {
      services.xserver.xkb.layout = "de";
      console.keyMap = "de";
      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "de_DE.UTF-8";
          LC_IDENTIFICATION = "de_DE.UTF-8";
          LC_MEASUREMENT = "de_DE.UTF-8";
          LC_MONETARY = "de_DE.UTF-8";
          LC_NAME = "de_DE.UTF-8";
          LC_NUMERIC = "de_DE.UTF-8";
          LC_PAPER = "de_DE.UTF-8";
          LC_TELEPHONE = "de_DE.UTF-8";
          LC_TIME = "de_DE.UTF-8";
        };
      };
    })
  ];
}
