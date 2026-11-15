{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
    ./hardware-configuration.nix
  ];

  config = {
    hardware = {
      enableAllHardware = lib.mkForce false;
      enableRedistributableFirmware = true;
      raspberry-pi.firmware = {
        enable = true;
        uboot.enable = true;
      };
    };

    boot = {
      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
      };
      consoleLogLevel = 2;
      supportedFilesystems.zfs = lib.mkForce false;
      kernel.sysctl."vm.swappiness" = 10;
    };

    # TODO: remove this when this is fixed: https://github.com/NixOS/nixpkgs/issues/154163
    # from: https://discourse.nixos.org/t/cannot-build-raspberry-pi-sdimage-module-dw-hdmi-not-found/71804/6
    # related: https://github.com/NixOS/nixpkgs/issues/109280
    # related: https://discourse.nixos.org/t/cannot-build-raspberry-pi-sdimage-module-dw-hdmi-not-found/71804
    boot.initrd.availableKernelModules = {
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

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = [
          "noatime"
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      libraspberrypi
      raspberrypi-eeprom
    ];
  };
}
