lib:

let
  ideOptionsFor =
    name: defaultPackage:
    with lib.types;
    lib.mkOption {
      default = null;
      type = nullOr (submodule {
        options = {
          enable = lib.mkEnableOption name;
          package = lib.mkOption {
            type = package;
            default = defaultPackage;
          };
          vmOptions = lib.mkOption {
            type = nullOr vmOptions;
            default = null;
          };
          __thisIsAnIde = { }; # marker for this type so we can automatically detect all IDE options later
        };
      });
    };

  vmOptions =
    with lib.types;
    submodule {
      options = {
        minMemory = lib.mkOption {
          type = nullOr ints.positive;
          default = null;
        };
        maxMemory = lib.mkOption {
          type = nullOr ints.positive;
          default = null;
        };
        awtBackend = lib.mkOption {
          type = nullOr (enum [
            "Wayland"
            "X11"
          ]);
          default = null;
        };
      };
    };
in
{
  inherit ideOptionsFor vmOptions;
}
