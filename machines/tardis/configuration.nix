{
  lib,
  pkgs,
  config,
  inputs,
  vars,
  overlays,
  ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-16-7040-amd
  ];

  ########## My NixOS modules #####################################################################

  my = {
    common-utilities.enable = true;
    desktop.plasma.enable = true;
    nix.enable = true;
    virtualisation = {
      enableDocker = true;
      enablePodman = true;
      enableLibvirtd = true;
      ociContainersBackend = "docker";
    };
  };

  programs.adb.enable = true;

  hardware.flipperzero.enable = true;
  services.hardware.openrgb.enable = true;

  ########## NixOS ################################################################################

  system.stateVersion = "26.05"; # Change with great care!

  nixpkgs = {
    config.allowUnfree = true;
    overlays = with overlays; [
      pkgs-stable
      my-lib
      my-pkgs
      json2nix
      rambo
    ];
  };

  ########## boot #################################################################################

  boot = {
    binfmt.emulatedSystems = [
      # Enable binfmt emulation of aarch64-linux for generating an image for the Raspberry Pi.
      "aarch64-linux"
    ];
    initrd.luks.devices."luks-2634ae65-a0f5-4938-aabe-52d2fc9f40aa".device =
      "/dev/disk/by-uuid/2634ae65-a0f5-4938-aabe-52d2fc9f40aa"; # Swap
    loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        configurationLimit = 30;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
    kernel.sysctl."vm.swappiness" = 10;
    kernelPackages = pkgs.linuxPackages_6_18;
  };

  ########## networking ###########################################################################

  networking = {
    hostName = vars.machine;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        53317 # LocalSend
      ];
      allowedUDPPorts = [
        53317 # LocalSend
      ];
    };
  };

  ########## services, sound, hardware ############################################################

  services = {
    flatpak.enable = true;
    fwupd.enable = true;
    pcscd.enable = true; # for YubiKey
    ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      rocmOverrideGfx = "11.0.2";
    };
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ]; # HP printer
    };
    avahi = {
      # for discovery of network devices like printers
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    xserver = {
      enable = true;
      xkb.layout = "de";
      videoDrivers = [ "amdgpu" ]; # is actually for X11 and Wayland
    };
    acpid = {
      enable = true;
      lidEventCommands =
        let
          goodixVendor = "27c6"; # lsusb | grep Goodix
        in
        # disable the fingerprint sensor when the laptop lid is closed
        # thanks to: https://github.com/NixOS/nixos-hardware/issues/1433
        lib.mkIf config.services.fprintd.enable ''
          grep -q closed /proc/acpi/button/lid/LID0/state
          if [ $? = 0 ]; then
            ${pkgs.fd}/bin/fd "-" /sys/bus/usb/devices --exec /bin/sh -c '${pkgs.gnugrep}/bin/grep -qs ${goodixVendor} {}/idVendor && ${pkgs.coreutils}/bin/echo 0 > {}/authorized'
            systemctl restart fprintd.service
          else
            ${pkgs.fd}/bin/fd "-" /sys/bus/usb/devices --exec /bin/sh -c '${pkgs.gnugrep}/bin/grep -qs ${goodixVendor} {}/idVendor && ${pkgs.coreutils}/bin/echo 1 > {}/authorized'
            systemctl restart fprintd.service
          fi
        '';
    };
  };

  security.rtkit.enable = true; # used by PipeWire

  # Workaround for the long wait time when logging in. Seems to be a bug in SDDM.
  # see: https://github.com/NixOS/nixpkgs/issues/239770#issuecomment-1868402338
  # This only disables the fingerprint for the login (after a boot or logout).
  # Using the fingerprint to unlock (get back from lock screen) and for sudo is still possible.
  security.pam.services.login.fprintAuth = false;

  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  ########## localization #########################################################################

  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  ########## users ################################################################################

  home-manager.users."${vars.user.name}" = ./home;

  users.users = {
    "${vars.user.name}" = {
      description = pkgs.my.lib.stringUtils.upperCaseFirstLetter vars.user.name;
      isNormalUser = true;
      home = vars.user.home;
      extraGroups = [
        "adbusers" # android debug bridge
        "dialout" # e.g. for espflash
        "networkmanager"
        "wheel"
      ];
    };
  };

  users.defaultUserShell = pkgs.zsh;

  ########## fonts ################################################################################

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
  ];

  ########## environment and programs #############################################################

  environment = {
    shells = [ pkgs.zsh ];
    pathsToLink = [ "/share/zsh" ];
  };

  programs = {
    nix-ld.enable = true; # run dynamically linked executables intended for generic Linux environments
    sniffnet.enable = true;
    steam.enable = true;
    zsh.enable = true;
  };
}
