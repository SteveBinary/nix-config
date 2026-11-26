{
  # On first install you typically let nixos-anywhere also generate the hardware-configuration.nix.
  # We replace it with the the hardware-configuration.nix generated on the final installed system.
  # If enableConfig=true, disko would modify the actual NixOS configuration to match the values below, e.g. setting the root file system.
  # But the values below are for the installer, not for the installed system, where we actually want to reference devices by ID.
  disko.enableConfig = false;

  # This layout should work on EFI and legacy BIOS systems.
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                preCreateHook = "sleep 3"; # there is a timing issue: https://github.com/nix-community/disko/issues/739
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
