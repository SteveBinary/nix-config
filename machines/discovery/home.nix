{ ... }:

{
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

  home.stateVersion = "26.05";
}
