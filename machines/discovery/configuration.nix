{
  pkgs,
  lib,
  vars,
  ...
}:

{
  ########## NixOS ################################################################################

  system.stateVersion = "26.05"; # Change with great care!

  nixpkgs.config.allowUnfree = true;

  ########## My NixOS modules #####################################################################

  my = {
    common-utilities.enable = true;
    nix = {
      enable = true;
      trusted-users = [ vars.user.name ];
    };
  };

  ########## boot ################################################################################

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    consoleLogLevel = 2;
    supportedFilesystems.zfs = lib.mkForce false;
    kernel.sysctl."vm.swappiness" = 10;
    kernelPackages = pkgs.linuxPackages_6_18;
  };

  ########## file systems #########################################################################

  fileSystems = {
    # this was not picked up by the hardware scan
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [
        # extend life of the SD card
        "noatime"
      ];
    };
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
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
      banner = lib.concatLines [
        # using https://manytools.org/hacker-tools/ascii-banner/ with font ANSI Shadow and horizontal/vertical spacing of Normal
        "██████╗ ██╗███████╗ ██████╗ ██████╗ ██╗   ██╗███████╗██████╗ ██╗   ██╗"
        "██╔══██╗██║██╔════╝██╔════╝██╔═══██╗██║   ██║██╔════╝██╔══██╗╚██╗ ██╔╝"
        "██║  ██║██║███████╗██║     ██║   ██║██║   ██║█████╗  ██████╔╝ ╚████╔╝ "
        "██║  ██║██║╚════██║██║     ██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗  ╚██╔╝  "
        "██████╔╝██║███████║╚██████╗╚██████╔╝ ╚████╔╝ ███████╗██║  ██║   ██║   "
        "╚═════╝ ╚═╝╚══════╝ ╚═════╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝   ╚═╝   "
      ];
    };
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
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

  ########## environment  #########################################################################

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];
}
