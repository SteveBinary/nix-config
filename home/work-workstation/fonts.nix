{ pkgs, ... }:

{
  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "Meslo" ];
  };

  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
  ];
}
