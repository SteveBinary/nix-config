{
  pkgs,
  lib,
  vars,
  ...
}:

{
  ########## NixOS ################################################################################

  system.stateVersion = "26.11"; # Change with great care!

  nixpkgs.config.allowUnfree = true;

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
    openssh = {
      enable = true;
      settings =
        let
          banner = pkgs.writeText "ssh-banner.txt" (
            lib.concatLines [
              # using https://manytools.org/hacker-tools/ascii-banner/ with font ANSI Shadow and horizontal/vertical spacing of Normal
              "██████╗ ██╗███████╗ ██████╗ ██████╗ ██╗   ██╗███████╗██████╗ ██╗   ██╗"
              "██╔══██╗██║██╔════╝██╔════╝██╔═══██╗██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝"
              "██║  ██║██║███████╗██║     ██║   ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ "
              "██║  ██║██║╚════██║██║     ██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  "
              "██████╔╝██║███████║╚██████╗╚██████╔╝ ╚████╔╝ ███████╗██║  ██║   ██║   "
              "╚═════╝ ╚═╝╚══════╝ ╚═════╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   "
            ]
          );
        in
        {
          PermitRootLogin = "prohibit-password";
          PasswordAuthentication = false;
          Banner = "${banner}";
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
