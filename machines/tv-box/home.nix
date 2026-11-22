{
  pkgs,
  ...
}:

{
  home.stateVersion = "26.11";

  my.development = {
    editors.helix.enable = true;
  };

  my.terminal = {
    fancyLS = true;
    shells = {
      bash.enable = true;
      zsh.enable = true;
    };
    tools = {
      atuin.enable = true;
      bat.enable = true;
      direnv.enable = true;
      fzf.enable = true;
      git = {
        enable = true;
        userName = "SteveBinary";
        userEmail = "60712092+SteveBinary@users.noreply.github.com";
      };
      oh-my-posh.enable = true;
      zellij.enable = true;
    };
  };

  my.browsers = {
    firefox = {
      enable = true;
      theme = "dark";
      uiDensity = "touch";
      extensions = {
        bitwarden.enable = true;
        plasmaBrowserIntegration.enable = true;
        uBlockOrigin.enable = true;
      };
    };
  };

  home.packages = with pkgs; [
    localsend
    spotify
  ];
}
