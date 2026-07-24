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
    ghostty.enable = true;
    fancyLS = true;
    clipboardAliasesBackend = "Wayland";
    shells = {
      bash.enable = true;
      zsh.enable = true;
    };
    tools = {
      atuin.enable = true;
      bat.enable = true;
      btop = {
        enable = true;
        package = pkgs.btop-rocm;
      };
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
    chromium.enable = true;
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
    settings = {
      "orville 192.168.100.50" = {
        HostName = "192.168.100.50";
        Port = 22;
        User = "steve";
        IdentityFile = config.sops.secrets."ssh_keys/id_orville_ed25519".path;
        IdentitiesOnly = true;
        PasswordAuthentication = "no";
        PubkeyAuthentication = "yes";
      };
      "discovery 192.168.178.25" = {
        Hostname = "192.168.178.25";
        Port = 22;
        User = "steve";
        IdentityFile = config.sops.secrets."ssh_keys/id_discovery_ed25519".path;
        IdentitiesOnly = true;
        PasswordAuthentication = "no";
        PubkeyAuthentication = "yes";
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
      "ssh_keys/id_discovery_ed25519" = {
        path = "${config.home.homeDirectory}/.ssh/id_discovery_ed25519";
      };
      "ssh_keys/id_discovery_ed25519_pub" = {
        path = "${config.home.homeDirectory}/.ssh/id_discovery_ed25519.pub";
      };
    };
  };

  home = {
    packages = with pkgs; [
      # desktop applications
      android-studio
      android-tools # TODO: might need to be put into the system packages
      # bitwarden-desktop
      bottles
      czkawka-full
      gimp
      handbrake
      haruna
      inkscape
      libreoffice-qt6-fresh
      localsend
      obsidian
      protonmail-bridge-gui
      proton-vpn
      rocmPackages.rocm-smi
      signal-desktop
      yubioath-flutter
      thunderbird
      vlc
      xeyes
      ytdownloader

      (llm-agents.claude-code.override { disableTelemetry = true; })

      my.json2nix
      my.rambo
      my.x86-64-level

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
      supertux
      supertuxkart

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
    stateVersion = "26.11";
  };

  programs.home-manager.enable = true;
}
