{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.services.litellm;
  createConfigFile = cfg.config != null;
  yamlFormat = pkgs.formats.yaml { };
in
{
  options.my.services.litellm = {
    enable = lib.mkEnableOption "Enable my Home Manager module for LiteLLM";
    # https://docs.litellm.ai/docs/proxy/config_settings
    config = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.path yamlFormat.type);
      default = null;
    };
    environment = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
      default = null;
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."litellm/config.yaml" = {
      enable = createConfigFile;
      source =
        if builtins.isPath cfg.config then cfg.config else yamlFormat.generate "config.yaml" cfg.config;
    };
    systemd.user.services.litellm = {
      Unit = {
        Description = "User service to run LiteLLM in the background.";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Environment = lib.mkIf (cfg.environment != null) (
          lib.map (elem: "${elem.name}=${elem.value}") (lib.attrsToList cfg.environment)
        );
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) (builtins.toString cfg.environmentFile);
        ExecStart = lib.strings.concatStringsSep " " [
          (lib.getExe pkgs.litellm)
          (lib.strings.optionalString createConfigFile "--config ${config.xdg.configHome}/litellm/config.yaml")
        ];
      };
    };
  };
}
