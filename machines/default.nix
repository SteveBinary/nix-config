{ inputs }:

let
  mkSystem =
    nixpkgs: params:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        inherit (params) vars;
        inherit (inputs.self) overlays;
      };
      modules = [
        ./${params.vars.machine}
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
              inherit inputs;
              inherit (params) vars;
            };
            sharedModules = [
              inputs.self.homeManagerModules.default
              inputs.plasma-manager.homeModules.plasma-manager
              inputs.sops-nix.homeManagerModules.sops
            ];
          };
        }
        {
          nixpkgs = {
            config.allowUnfree = true;
            overlays = with inputs.self.overlays; [
              pkgs-stable
              my-lib
              my-pkgs
            ];
          };
        }
      ]
      ++ params.extraModules or [ ];
    };
in
{
  discovery = mkSystem inputs.nixpkgs {
    vars = rec {
      machine = "discovery";
      user.name = "steve";
      user.home = "/home/${user.name}";
    };
    extraModules = [
      inputs.self.nixosModules.hardware-raspberry-pi-4
    ];
  };

  orville = mkSystem inputs.nixpkgs-stable {
    vars = rec {
      machine = "orville";
      user.name = "steve";
      user.home = "/home/${user.name}";
    };
  };

  tardis = mkSystem inputs.nixpkgs {
    vars = rec {
      machine = "tardis";
      user.name = "steve";
      user.home = "/home/${user.name}";
    };
    extraModules = [
      inputs.self.nixosModules.hardware-framework-laptop-16-7040-amd
    ];
  };

  tv-box = mkSystem inputs.nixpkgs {
    vars = rec {
      machine = "tv-box";
      user.name = "steve";
      user.home = "/home/${user.name}";
    };
    extraModules = [
      inputs.self.nixosModules.hardware-raspberry-pi-5
    ];
  };
}
