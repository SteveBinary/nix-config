{
  pkgs,
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
    my-pkgs
  ];

  my.development = {
    editors = {
      helix.enable = true;
      jetbrains = {
        defaultVMOptions = {
          minMemory = 2048;
          maxMemory = 16384;
        };
        intellij.enable = true;
        pycharm.enable = true;
        goland.enable = true;
        rider.enable = true;
        rustrover.enable = true;
      };
      vscode.enable = true;
      zed = {
        enable = true;
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
    kitty.enable = true;
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
      gh
      keepassxc
      localsend
      vlc

      my.x86-64-level
    ];

    sessionVariables = {
      GRADLE_USER_HOME = "${config.home.homeDirectory}/.gradle";
    };

    username = vars.user.name;
    homeDirectory = vars.user.home;
    preferXdgDirectories = true;
    stateVersion = "26.05";
  };

  sops.secrets = {
    git_user_information = { };
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
  };

  targets.genericLinux = {
    enable = true;
    # This allows GPU-programs to find the drivers in their expected location.
    # The initial install or occasional driver update require manually running the 'non-nixos-gpu-setup' script.
    # Instructions are printed on activation in the 'checkExistingGpuDrivers' stage.
    # See: https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-non-nixos
    gpu.enable = true;
  };
}
