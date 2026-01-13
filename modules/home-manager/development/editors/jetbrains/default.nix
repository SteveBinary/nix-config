{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.development.editors.jetbrains;
  types = import ./types.nix lib;
in
{
  options.my.development.editors.jetbrains = with types; {
    defaultVMOptions = lib.mkOption {
      type = lib.types.nullOr vmOptions;
      default = null;
    };
    clion = ideOptionsFor "CLion" pkgs.jetbrains.clion;
    goland = ideOptionsFor "GoLand" pkgs.jetbrains.goland;
    intellij = ideOptionsFor "IntelliJ" pkgs.jetbrains.idea;
    rider = ideOptionsFor "Rider" pkgs.jetbrains.rider;
    phpstorm = ideOptionsFor "PhpStorm" pkgs.jetbrains.phpstorm;
    pycharm = ideOptionsFor "PyCharm" pkgs.jetbrains.pycharm;
    rustrover = ideOptionsFor "RustRover" pkgs.jetbrains.rust-rover;
    webstorm = ideOptionsFor "WebStorm" pkgs.jetbrains.webstorm;
  };

  config =
    let
      checkVmOptions =
        name: vmOptions:
        with vmOptions;
        lib.throwIf (minMemory != null && maxMemory != null && minMemory > maxMemory)
          "${name}: vmOptions.minMemory (${toString minMemory}) cannot be greater than vmOptions.maxMemory (${toString maxMemory})"
          vmOptions;

      renderVmOptions =
        options:
        let
          rendered = lib.concatLines (
            lib.filter (line: line != "") [
              (lib.optionalString (options.minMemory != null) "-Xms${toString (options.minMemory)}m")
              (lib.optionalString (options.maxMemory != null) "-Xmx${toString (options.maxMemory)}m")
              (lib.optionalString (options.awtBackend == "Wayland") "-Dawt.toolkit.name=WLToolkit")
              (lib.optionalString (options.awtBackend == "X11") "-Dawt.toolkit.name=XToolkit")
            ]
          );
        in
        if lib.trim rendered == "" then null else rendered;

      mergeAttrsOfNullables =
        left: right:
        if left != null && right != null then
          left // lib.filterAttrs (_: attr: attr != null) right
        else if left == null && right != null then
          right
        else if left != null && right == null then
          left
        else
          null;

      ideCfgToPackage =
        optionKey: ideCfg:
        lib.mkIf
          (
            ideCfg != null
            && lib.hasAttr "__thisIsAnIde" ideCfg # check for the custom marker to only take actual IDE options into account
            && ideCfg.enable
          )
          (
            ideCfg.package.override {
              vmopts = lib.mapNullable renderVmOptions (
                lib.mapNullable (checkVmOptions optionKey) (
                  mergeAttrsOfNullables cfg.defaultVMOptions ideCfg.vmOptions
                )
              );
            }
          );
    in
    {
      # automatically generate the packages for all IDE-like options in cfg
      home.packages = lib.mapAttrsToList (
        optionKey: ideOptions: ideCfgToPackage optionKey ideOptions
      ) cfg;
    };
}
