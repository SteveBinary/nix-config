{
  pkgs,
  vars,
  overlays,
  ...
}:

{
  ########## My NixOS modules #####################################################################

  my = {
    common-utilities.enable = true;
    desktop.plasma.enable = true;
    gaming.steam.enable = true;
    programs.probe-rs-tools.enable = true;
    nix.enable = true;
    virtualisation = {
      enableDocker = true;
      enablePodman = true;
      enableLibvirtd = true;
      ociContainersBackend = "docker";
    };
  };

  ########## NixOS ################################################################################

  system.stateVersion = "26.11"; # Change with great care!

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
    kernelPackages = pkgs.linuxPackages_7_3;
    binfmt.emulatedSystems = [
      # Enable binfmt emulation of aarch64-linux for generating an image for the Raspberry Pi.
      "aarch64-linux"
    ];
    initrd.luks.devices."luks-2634ae65-a0f5-4938-aabe-52d2fc9f40aa".device =
      "/dev/disk/by-uuid/2634ae65-a0f5-4938-aabe-52d2fc9f40aa"; # Swap
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
    hardware.openrgb.enable = true;
    pcscd.enable = true; # for YubiKey
    ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      rocmOverrideGfx = "11.0.3";
      environmentVariables = {
        OLLAMA_NO_CLOUD = "1";
        OLLAMA_IGPU_ENABLE = "1";
        OLLAMA_KEEP_ALIVE = "1h";
      };
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
    };
    xserver = {
      enable = true;
      xkb.layout = "de";
      videoDrivers = [ "amdgpu" ]; # is actually for X11 and Wayland
    };
  };

  security.rtkit.enable = true; # used by PipeWire

  hardware = {
    bluetooth.enable = true;
    flipperzero.enable = true;
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

  users.users = {
    "${vars.user.name}" = {
      description = pkgs.my.lib.stringUtils.upperCaseFirstLetter vars.user.name;
      isNormalUser = true;
      home = vars.user.home;
      extraGroups = [
        "wheel"
        "networkmanager"
        # "adbusers" # android debug bridge

        # interfacing with external devices like ESP32 and Raspberry Pi Pico
        "dialout"
        "plugdev"
      ];
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
