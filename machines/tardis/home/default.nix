{
  pkgs,
  lib,
  config,
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
      zed = {
        enable = true;
        fontSizes = {
          ui = 18;
          editor = 14;
          terminal = 14;
        };
      };
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
    nextcloud-client.enable = true;
  };

  my.browsers = {
    firefox = {
      enable = true;
      theme = "dark";
      extensions = {
        bitwarden.enable = true;
        plasmaBrowserIntegration.enable = true;
        uBlockOrigin.enable = true;

        # Sidebery config file: /assets/sidebery.config.json
        # for import into Sidebery:
        #   -> go into the Sidebery settings
        #   -> at the bottom: import addon data
        #   -> select the config file
        # for export from Sidebery:
        #   -> go into the Sidebery settings
        #   -> at the bottom: export addon data (turn OFF "Snapshots" and "Sites icon chache")
        #   -> format the file and replace the old config with the new one
        sidebery.enable = true;
      };
    };
  };

  my.misc = {
    virt-manager-extra.enable = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "orville 192.168.100.50" = {
        hostname = "192.168.100.50";
        port = 22;
        user = "steve";
        identityFile = config.sops.secrets."ssh_keys/id_orville_ed25519".path;
        identitiesOnly = true;
        extraOptions = {
          PasswordAuthentication = "no";
          PubkeyAuthentication = "yes";
        };
      };
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      "ssh_keys/id_orville_ed25519" = {
        path = "${config.home.homeDirectory}/.ssh/id_orville_ed25519";
      };
      "ssh_keys/id_orville_ed25519_pub" = {
        path = "${config.home.homeDirectory}/.ssh/id_orville_ed25519.pub";
      };
    };
  };

  home = {
    packages = with pkgs; [
      # desktop applications
      android-studio
      bitwarden-desktop
      bottles
      czkawka-full
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
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
