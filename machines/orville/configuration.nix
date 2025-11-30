{
  pkgs,
  lib,
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
    virtualisation = {
      enableDocker = true;
      ociContainersBackend = "docker";
    };
    nix = {
      enable = true;
      trusted-users = [ vars.user.name ];
    };
  };

  ########## NixOS ################################################################################

  system.stateVersion = "25.11"; # Change with great care!

  nixpkgs.config.allowUnfree = true;

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
    kernelPackages = pkgs.linuxPackages_6_12;
  };

  ########## networking ###########################################################################

  networking = {
    hostName = vars.machine;
    firewall.enable = true;
    defaultGateway = "192.168.100.1";
    nameservers = [ "192.168.100.1" ];
    interfaces.enp5s0.ipv4.addresses = [
      {
        address = "192.168.100.50";
        prefixLength = 24;
      }
    ];
  };

  ########## services #############################################################################

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
      banner = lib.concatLines [
        # using https://manytools.org/hacker-tools/ascii-banner/ with font ANSI Shadow and horizontal/vertical spacing of Normal
        " ██████╗ ██████╗ ██╗   ██╗██╗██╗     ██╗     ███████╗"
        "██╔═══██╗██╔══██╗██║   ██║██║██║     ██║     ██╔════╝"
        "██║   ██║██████╔╝██║   ██║██║██║     ██║     █████╗  "
        "██║   ██║██╔══██╗╚██╗ ██╔╝██║██║     ██║     ██╔══╝  "
        "╚██████╔╝██║  ██║ ╚████╔╝ ██║███████╗███████╗███████╗"
        " ╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚═╝╚══════╝╚══════╝╚══════╝"
      ];
    };
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
    rpcbind.enable = true; # needed for NFS
  };

  ########## localizaiton #########################################################################

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";

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

  virtualisation.incus.agent.enable = true;

  environment.systemPackages = with pkgs; [
    age
    gitMinimal
    sops
  ];
}
