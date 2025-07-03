{
  pkgs,
  lib,
  vars,
  inputs,
  ...
}:

{
  imports = [
    ./home-files.nix
  ];

  my.desktops.plasma.enable = true;

  my.programs = {
    development.editors = {
      helix.enable = true;
      zed.enable = true;
      jetbrains = {
        defaultVMOptions = {
          minMemory = 2048;
          maxMemory = 16384;
        };
        rustrover = {
          enable = true;
          vmOptions.awtBackend = "Wayland";
        };
      };
    };
    git = {
      enable = true;
      userName = "SteveBinary";
      userEmail = "60712092+SteveBinary@users.noreply.github.com";
      askpass = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    };
    shells = {
      fancyLS = true;
      clipboardAliasesBackend = "Wayland";
      bash.enable = true;
      zsh.enable = true;
    };
    kitty.enable = true;
    oh-my-posh.enable = true;
    zellij.enable = true;
    bat.enable = true;
    direnv.enable = true;
    fzf.enable = true;
    utilities.enable = true;
    virt-manager-extra.enable = true;
  };

  my.services = {
    kde-connect.enable = true;
    nextcloud-client.enable = true;
  };

  home = {
    packages = with pkgs; [
      # desktop applications
      bitwarden-desktop
      bottles
      czkawka-full
      element-desktop
      firefox
      handbrake
      haruna
      inkscape
      libreoffice-qt6-fresh
      localsend
      obsidian
      protonmail-bridge-gui
      signal-desktop
      thunderbird
      vlc
      xorg.xeyes
      ytdownloader

      # issue: https://github.com/nix-community/home-manager/issues/5173
      # original: https://github.com/NixOS/nixpkgs/issues/254265
      # using this workaround: https://discourse.nixos.org/t/home-manager-collision-with-app-lib/51969/2
      (lib.hiPrio rustdesk-flutter)

      # spellchecking and hyphenation, mostly for LibreOffice
      hunspell
      hunspellDicts.de_DE
      hyphenDicts.de_DE

      # games
      oh-my-git
      superTux
      superTuxKart

      # terminal applications
      gcc # mainly to not need to open RustRover from the nix shell
      inputs.rambo.packages."${pkgs.system}".default
    ];

    sessionVariables = {
      SSH_ASKPASS_REQUIRE = "prefer";
    };

    username = vars.user.name;
    homeDirectory = vars.user.home;
    preferXdgDirectories = true;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
