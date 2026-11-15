{
  pkgs,
  lib,
  ...
}:

{
  # currently, there is no need to depend on the NixOS/nixos-hardware module
  imports = [
    ./hardware-configuration.nix
  ];

  config = {
    boot = {
      loader = {
        grub.enable = false;
        generic-extlinux-compatible.enable = true;
      };
      consoleLogLevel = 2;
      supportedFilesystems.zfs = lib.mkForce false;
      kernel.sysctl."vm.swappiness" = 10;
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
