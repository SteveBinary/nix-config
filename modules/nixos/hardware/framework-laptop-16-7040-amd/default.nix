{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-16-7040-amd
  ];

  config = {
    # Prevent screen artifacts. This negatively impacts battery life ...
    # TODO: this might get fixed upstream at some point (nixos-hardware or kernel)
    # see: https://github.com/NixOS/nixos-hardware/pull/1692
    boot.kernelParams = lib.mkAfter [ "amdgpu.dcdebugmask=0x410" ];

    boot = {
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
    };

    # disable the fingerprint sensor when the laptop lid is closed
    # thanks to: https://github.com/NixOS/nixos-hardware/issues/1433
    services.acpid = {
      enable = true;
      lidEventCommands =
        let
          goodixVendor = "27c6"; # lsusb | grep Goodix
        in
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
}
