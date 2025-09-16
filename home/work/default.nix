{
  pkgs,
  inputs,
  overlays,
  vars,
  config,
  ...
}:

{
  imports = [
    ./fonts.nix
    ./home-files.nix
  ];

  nixpkgs.overlays = with overlays; [
    pkgs-before-plasma5-drop
    my-lib
  ];

  my.development = {
    editors = {
      helix.enable = true;
      jetbrains = {
        defaultVMOptions = {
          minMemory = 2048;
          maxMemory = 16384;
        };
        intellij = {
          enable = true;
          package = pkgs.jetbrains.idea-ultimate;
        };
        goland.enable = true;
        rider.enable = true;
        rustrover.enable = true;
      };
      vscode.enable = true;
      zed = {
        enable = true;
        package = config.lib.nixGL.wrap pkgs.zed-editor;
        fontSizes = {
          ui = 12;
          editor = 10;
          terminal = 10;
        };
      };
    };
    kubernetes.enable = true;
    mqtt-explorer = {
      enable = true;
      noSandbox = true;
    };
  };

  my.terminal = {
    kitty = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.kitty;
    };
    fancyLS = true;
    clipboardAliasesBackend = "X11";
    shells = {
      bash = {
        enable = true;
        bashrcExtra = ''
          # changing the default shell for a user is not allowed, so this workaround is needed
          if [ -z "$ZSH_VERSION" ]; then exec ${config.home.homeDirectory}/.nix-profile/bin/zsh; fi
        '';
      };
      zsh.enable = true;
    };
    tools = {
      atuin.enable = true;
      bat.enable = true;
      direnv.enable = true;
      fzf.enable = true;
      git = {
        enable = true;
        askpass = "${pkgs.before-plasma5-drop.libsForQt5.ksshaskpass}/bin/ksshaskpass";
        includes = [ { path = config.sops.secrets.git_user_information.path; } ];
      };
      oh-my-posh.enable = true;
      utilities.enable = true;
      zellij.enable = true;
    };
  };

  my.browsers = {
    firefox = {
      enable = true;
      theme = "dark";
      defaultSearchEngine = "google";
      enableAppArmorPreparationForUbuntu = true;
      extensions = {
        plasmaBrowserIntegration = {
          enable = true;
          nativeMessagingHostPackage = pkgs.before-plasma5-drop.libsForQt5.plasma-browser-integration;
        };
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

  home = {
    packages = with pkgs; [
      keepass
      vlc
    ];

    sessionVariables = {
      GRADLE_USER_HOME = "${config.home.homeDirectory}/.gradle";
    };

    username = vars.user.name;
    homeDirectory = vars.user.home;
    preferXdgDirectories = true;
    stateVersion = "25.11";
  };

  sops.secrets = {
    git_user_information = { };
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
  };

  nixGL = {
    packages = inputs.nixgl.packages;
    vulkan.enable = true;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
  };

  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
    # nixpkgs-stable.flake = inputs.nixpkgs-stable;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  news.display = "silent";
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;
}
