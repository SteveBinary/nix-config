{ inputs }:

let
  mkSystem =
    nixpkgs: vars:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs vars;
        inherit (inputs.self) overlays;
      };
      modules = [
        ./${vars.machine}
        inputs.self.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        {
          # prepare for the use of Home Manager, so that the machine configuration just needs to declare the users
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit vars;
            };
            sharedModules = [
              inputs.self.homeManagerModules.default
              inputs.plasma-manager.homeModules.plasma-manager
              inputs.sops-nix.homeManagerModules.sops
            ];
          };
        }
      ];
    };
in
{
  discovery = mkSystem inputs.nixpkgs rec {
    machine = "discovery";
    user.name = "steve";
    user.home = "/home/${user.name}";
  };

  orville = mkSystem inputs.nixpkgs-stable rec {
    machine = "orville";
    user.name = "steve";
    user.home = "/home/${user.name}";
  };

  tardis = mkSystem inputs.nixpkgs rec {
    machine = "tardis";
    user.name = "steve";
    user.home = "/home/${user.name}";
  };
}
