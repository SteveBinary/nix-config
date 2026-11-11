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
  discovery-sdcard-image = mkAarch64SdCardImageFromNixosConfiguration inputs.self.nixosConfigurations.discovery;
  x86-64-level = pkgs.callPackage ./x86-64-level { };
}
