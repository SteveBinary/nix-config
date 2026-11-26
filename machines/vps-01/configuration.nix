{
  pkgs,
  lib,
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

  ########## boot ################################################################################

  boot.loader.grub = {
    enable = true;
    configurationLimit = 10;
    # force will make it work on install with nixos-anywhere + disko and later when installed,
    # because disko also sets it to [ "/dev/sda" ], which would duplicate "/dev/sda"
    devices = lib.mkForce [ "/dev/sda" ];
  };

  ########## networking ###########################################################################

  networking = {
    hostName = vars.machine;
    useDHCP = true;
    firewall.enable = true;
  };

  ########## secrets ##############################################################################

  # The key needs to be present on the target host!
  # It was generated on the installed machine via: age-keygen -pq -o ~/.config/sops/age/keys.txt
  sops.age.keyFile = "${vars.user.home}/.config/sops/age/keys.txt";

  ########## users ################################################################################

  users = {
    mutableUsers = true; # we need to be able to change the password after initial user creation
    users = {
      ${vars.user.name} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        home = vars.user.home;
        initialHashedPassword = "$y$j9T$rxOmprOnDESXzo7yMl.zZ/$gP/k6vFvRSOIkLynI6BcCaOMs3Xn4.CAL734g67TXmD";
        openssh.authorizedKeys.keys = vars.user.authorizedKeys;
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
