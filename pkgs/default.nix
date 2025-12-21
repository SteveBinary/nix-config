{ pkgs, inputs }:

{
  discovery-sdcard-image = inputs.self.nixosConfigurations.discovery.config.system.build.sdImage;
  x86-64-level = pkgs.callPackage ./x86-64-level { };
}
