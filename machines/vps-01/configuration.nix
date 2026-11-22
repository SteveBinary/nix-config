{
  pkgs,
  vars,
  ...
}:

{
  ########## My NixOS modules #####################################################################

  my = {
    common-utilities.enable = true;
    localization.language = "en_de";
    nix = {
      enable = true;
      trusted-users = [ vars.user.name ];
    };
    services.openssh = {
      enable = true;
      port = 36921;
      allowedUser = vars.user.name;
    };
    terminfo.enableGhostty = true;
    virtualisation = {
      enableDocker = true;
      ociContainersBackend = "docker";
    };
  };

  ########## NixOS ################################################################################

  system.stateVersion = "26.11"; # Change with great care!

  ########## boot ################################################################################

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
    configurationLimit = 10;
  };

  ########## networking ###########################################################################

  networking = {
    hostName = vars.machine;
    useDHCP = true;
    firewall.enable = true;
  };

  ########## users ################################################################################

  users = {
    mutableUsers = true; # we need to be able to change the password after initial user creation
    users =
      let
        sshAuthorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIfhNXGZVzHnCFtFZWgoi4fCtEJAD0glDTS2Z3wDs8eu vps-01"
        ];
      in
      {
        "${vars.user.name}" = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          home = vars.user.home;
          initialHashedPassword = "$y$j9T$rxOmprOnDESXzo7yMl.zZ/$gP/k6vFvRSOIkLynI6BcCaOMs3Xn4.CAL734g67TXmD";
          openssh.authorizedKeys.keys = sshAuthorizedKeys;
        };
      };
  };

  ########## environment  #########################################################################

  environment.systemPackages = with pkgs; [
    age
    gitMinimal
    sops
  ];
}
