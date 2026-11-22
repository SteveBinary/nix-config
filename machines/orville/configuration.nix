{
  pkgs,
  config,
  vars,
  ...
}:

{
  imports = [
    ./container-services
    ./mounts.nix
  ];

  ########## My NixOS modules #####################################################################

  my = {
    common-utilities.enable = true;
    localization.language = "en_de";
    nix = {
      enable = true;
      trusted-users = [ vars.user.name ];
    };
    virtualisation = {
      enableDocker = true;
      ociContainersBackend = "docker";
    };
  };

  ########## NixOS ################################################################################

  system.stateVersion = "25.11"; # Change with great care!

  ########## Secrets ##############################################################################

  sops = {
    age.keyFile = "${vars.user.home}/.config/sops/age/keys.txt"; # the key needs to be present on the target host
    secrets = {
      "user/hashed_password" = {
        sopsFile = ./secrets.yaml;
        neededForUsers = true;
      };
    };
  };

  ########## boot ################################################################################

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 30;
      };
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "nfs" ];
    kernel.sysctl."vm.swappiness" = 10;
    kernelParams = [ "pcie_aspm=off" ];
  };

  ########## networking ###########################################################################

  networking = {
    hostName = vars.machine;
    firewall.enable = true;
    defaultGateway = "192.168.100.1";
    nameservers = [ "192.168.100.1" ];
    useDHCP = false;
    interfaces.ens3.ipv4.addresses = [
      {
        address = "192.168.100.50";
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
    rpcbind.enable = true; # needed for NFS
  };

  ########## users ################################################################################

  users = {
    mutableUsers = false;
    users =
      let
        sshAuthorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBhJ8AAl4pGSIH3m4+ok3cwKHJqvI6Chi4QJprSNvBw8 orville"
        ];
      in
      {
        "${vars.user.name}" = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          home = vars.user.home;
          hashedPasswordFile = config.sops.secrets."user/hashed_password".path;
          openssh.authorizedKeys.keys = sshAuthorizedKeys;
        };
        root = {
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
