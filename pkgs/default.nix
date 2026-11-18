{ pkgs, inputs }:

let
  mkAarch64SdCardImageFromNixosConfiguration =
    nixosConfiguration:
    (nixosConfiguration.extendModules {
      modules = [
        (
          { modulesPath, vars, ... }:
          {
            imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ];
            sdImage.compressImage = false;
            image.baseName = "nixos-aarch64-${vars.machine}-sdcard";
          }
        )
      ];
    }).config.system.build.sdImage;
in
{
  benchmark-cpu = pkgs.callPackage ./benchmark/cpu.nix { };
  hetzner-cost-optimized-availability-watcher = pkgs.callPackage ./hetzner-watcher { };
  x86-64-level = pkgs.callPackage ./x86-64-level { };

  discovery-sdcard-image = mkAarch64SdCardImageFromNixosConfiguration inputs.self.nixosConfigurations.discovery;
  tv-box-sdcard-image = mkAarch64SdCardImageFromNixosConfiguration inputs.self.nixosConfigurations.tv-box;
}
