{
  pkgs,
  config,
  vars,
  ...
}:

{
  ########## NixOS ################################################################################

  system.stateVersion = "26.11"; # Change with great care!

  ########## My NixOS modules #####################################################################

  my = {
    common-utilities.enable = true;
    desktop.plasma-bigscreen = {
      enable = true;
      autoLoginUser = vars.user.name;
    };
    localization.language = "de";
    nix = {
      enable = true;
      trusted-users = [ vars.user.name ];
    };
    terminfo.enableGhostty = true;
  };

  ########## hardware #############################################################################

  hardware = {
    bluetooth.enable = true;
  };

  ########## networking ###########################################################################

  networking = {
    hostName = vars.machine;
    firewall.enable = true;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

  ########## services #############################################################################

  services = {
    # TODO: use my.services.openssh
    openssh = {
      enable = true;
      settings = {
        Banner = pkgs.my.lib.sshBanner config.networking.hostName;
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
    flatpak.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security.rtkit.enable = true; # used by PipeWire

  ########## users ################################################################################

  users = {
    mutableUsers = false;
    users =
      let
        sshAuthorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHve+hC9S0UZx5c4uMDZElZgd1FWOLkvH6omc/2b9Hdf tv-box"
        ];
      in
      {
        "${vars.user.name}" = {
          uid = 1000;
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "networkmanager"
          ];
          home = vars.user.home;
          hashedPassword = "$y$j9T$id4BLhGoR56bGO.tcgmBB0$yjhsYQRVakyRHlARALr7FEwDf0Q.6Ib.iW3CtoXpA5D";
          openssh.authorizedKeys.keys = sshAuthorizedKeys;
        };
        root = {
          openssh.authorizedKeys.keys = sshAuthorizedKeys;
        };
      };
  };

  ########## fonts ################################################################################

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
  ];

  ########## zsh as default shell #################################################################

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment = {
    shells = [ pkgs.zsh ];
    pathsToLink = [ "/share/zsh" ];
  };
}
