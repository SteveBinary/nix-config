{
  pkgs,
  lib,
  inputs,
  vars,
  ...
}:

{
  ########## Raspberry Pi #########################################################################

  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
  ];

  hardware = {
    bluetooth.enable = true;
    graphics.enable = true;

    # Raspberry Pi specifics
    enableAllHardware = lib.mkForce false;
    enableRedistributableFirmware = true;
    raspberry-pi.firmware = {
      enable = true;
      uboot.enable = true;
    };
  };

  boot.initrd.availableKernelModules = {
    # TODO: remove this when this is fixed: https://github.com/NixOS/nixpkgs/issues/154163
    # from: https://discourse.nixos.org/t/cannot-build-raspberry-pi-sdimage-module-dw-hdmi-not-found/71804/6
    # related: https://github.com/NixOS/nixpkgs/issues/109280
    # related: https://discourse.nixos.org/t/cannot-build-raspberry-pi-sdimage-module-dw-hdmi-not-found/71804
    dw-hdmi = lib.mkForce false;
    dw-mipi-dsi = lib.mkForce false;
    rockchipdrm = lib.mkForce false;
    rockchip-rga = lib.mkForce false;
    phy-rockchip-pcie = lib.mkForce false;
    pcie-rockchip-host = lib.mkForce false;
    pwm-sun4i = lib.mkForce false;
    sun4i-drm = lib.mkForce false;
    sun8i-mixer = lib.mkForce false;

    tpm-crb = lib.mkForce false;
  };

  ########## NixOS ################################################################################

  system.stateVersion = "26.11"; # Change with great care!

  nixpkgs.config.allowUnfree = true;

  ########## My NixOS modules #####################################################################

  my = {
    common-utilities.enable = true;
    desktop.plasma-bigscreen = {
      enable = true;
      autoLoginUser = vars.user.name;
    };
    nix = {
      enable = true;
      trusted-users = [ vars.user.name ];
    };
    terminfo.enableGhostty = true;
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
  };

  ########## file systems #########################################################################

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [
        "noatime"
      ];
    };
  };

  ########## networking ###########################################################################

  networking = {
    hostName = vars.machine;
    firewall.enable = true;
    defaultGateway = "192.168.178.1";
    nameservers = [ "192.168.178.25" ]; # discovery
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

  ########## services #############################################################################

  services = {
    openssh = {
      enable = true;
      settings =
        let
          banner = pkgs.writeText "ssh-banner.txt" (
            lib.concatLines [
              # using https://manytools.org/hacker-tools/ascii-banner/
              # with font ANSI Shadow and horizontal/vertical spacing of Normal and the shodow manually removed
              "████████ ██    ██       ██████   ██████  ██   ██"
              "   ██    ██    ██       ██   ██ ██    ██  ██ ██ "
              "   ██    ██    ██ █████ ██████  ██    ██   ███  "
              "   ██     ██  ██        ██   ██ ██    ██  ██ ██ "
              "   ██      ████         ██████   ██████  ██   ██"
            ]
          );
        in
        {
          PermitRootLogin = "prohibit-password";
          PasswordAuthentication = false;
          Banner = "${banner}";
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

  ########## localization #########################################################################

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";
  i18n.defaultLocale = "de_DE.UTF-8";
  services.xserver.xkb.layout = "de"; # KDE Plasma seems to adhere to this

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
