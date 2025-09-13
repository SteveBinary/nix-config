{
  pkgs,
  lib,
  vars,
  ...
}:

{
  imports = [
    ./home-files.nix
  ];

  my.desktops = {
    plasma.enable = true;
  };

  my.development = {
    editors = {
      helix.enable = true;
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
      zed.enable = true;
    };
  };

  my.terminal = {
    kitty.enable = true;
    fancyLS = true;
    clipboardAliasesBackend = "Wayland";
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
        askpass = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
      };
      oh-my-posh.enable = true;
      zellij.enable = true;
    };
  };

  my.services = {
    kde-connect.enable = true;
    nextcloud-client.enable = true;
  };

  my.browsers = {
    firefox.enable = true;
  };

  my.misc = {
    virt-manager-extra.enable = true;
  };

  home = {
    packages = with pkgs; [
      # desktop applications
      bitwarden-desktop
      bottles
      czkawka-full
      element-desktop
      handbrake
      haruna
      inkscape
      libreoffice-qt6-fresh
      localsend
      obsidian
      protonmail-bridge-gui
      signal-desktop
      stable.yubioath-flutter
      thunderbird
      vlc
      xorg.xeyes
      ytdownloader

      my.json2nix
      my.rambo

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
      rustup
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
