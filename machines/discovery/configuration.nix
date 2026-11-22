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
    localization.language = "en_de";
    nix = {
      enable = true;
      trusted-users = [ vars.user.name ];
    };
    terminfo.enableGhostty = true;
  };

  ########## networking ###########################################################################

  networking = {
    hostName = vars.machine;
    firewall.enable = true;
    defaultGateway = "192.168.178.1";
    nameservers = [ "192.168.178.1" ];
    interfaces.eth0.ipv4.addresses = [
      {
        address = "192.168.178.25";
        prefixLength = 24;
      }
    ];
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
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };

  ########## users ################################################################################

  users = {
    mutableUsers = false;
    users =
      let
        sshAuthorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFS9+5OcvdqwTxDbfw1K0ylYTlLxKZEXDL2mcZLSzLx9 discovery"
        ];
      in
      {
        "${vars.user.name}" = {
          uid = 1000;
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          home = vars.user.home;
          hashedPassword = "$y$j9T$sIOE8k/IG3z2gd8GiUg8E0$vI9TA5TRKTj/RNHdg8K7HRSMriwKc6f68GPWD79YYl3";
          openssh.authorizedKeys.keys = sshAuthorizedKeys;
        };
        root = {
          openssh.authorizedKeys.keys = sshAuthorizedKeys;
        };
      };
  };
}
