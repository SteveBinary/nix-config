{
  description = "Modular flake-based nix-config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-before-plasma5-drop.url = "github:NixOS/nixpkgs/25303238b95d1eef8109aa76f8de084bf8eeb178";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rambo = {
      url = "github:SteveBinary/rambo";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    json2nix = {
      url = "github:SteveBinary/json2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    {
      nixosConfigurations = {
        tardis = inputs.nixpkgs.lib.nixosSystem (
          let
            vars = {
              machine = "tardis";
              system = "x86_64-linux";
              user.name = "steve";
              user.home = "/home/${vars.user.name}";
            };
            specialArgs = {
              inherit inputs vars;
              inherit (inputs.self) overlays;
            };
          in
          {
            inherit specialArgs;
            modules = [
              ./machines/${vars.machine}
              ./modules/nixos
              inputs.sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${vars.user.name} = ./home/${vars.user.name};
                home-manager.extraSpecialArgs = specialArgs;
                home-manager.sharedModules = [
                  ./modules/home-manager
                  inputs.plasma-manager.homeModules.plasma-manager
                  inputs.sops-nix.homeManagerModules.sops
                ];
              }
            ];
          }
        );
        orville = inputs.nixpkgs-stable.lib.nixosSystem (
          let
            vars = {
              machine = "orville";
              user.name = "steve";
              user.home = "/home/${vars.user.name}";
            };
          in
          {
            specialArgs = { inherit inputs vars; };
            modules = [
              ./machines/${vars.machine}
              ./modules/nixos
              inputs.disko.nixosModules.disko
              inputs.sops-nix.nixosModules.sops
            ];
          }
        );
      };
      homeConfigurations = {
        work = inputs.home-manager.lib.homeManagerConfiguration (
          let
            vars = {
              system = "x86_64-linux";
              user.name = builtins.getEnv "USER"; # requires '--impure' when doing 'home-manager switch'
              user.home = "/home/${vars.user.name}";
            };
            pkgs = inputs.nixpkgs.legacyPackages.${vars.system};
          in
          {
            inherit pkgs;
            extraSpecialArgs = {
              inherit inputs vars;
              inherit (inputs.self) overlays;
            };
            modules = [
              ./home/work
              ./modules/home-manager
              inputs.sops-nix.homeManagerModules.sops
              inputs.plasma-manager.homeModules.plasma-manager
            ];
          }
        );
      };
    }
    // inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            age
            just
            nix-output-monitor
            sops
          ];
        };
      }
    )
    // {
      overlays = {
        pkgs-stable = final: prev: {
          stable = import inputs.nixpkgs-stable {
            inherit (prev) system;
            config.allowUnfree = true;
          };
        };
        pkgs-before-plasma5-drop = final: prev: {
          before-plasma5-drop = import inputs.nixpkgs-before-plasma5-drop {
            inherit (prev) system;
            config.allowUnfree = true;
          };
        };
        my-lib = final: prev: {
          my = prev.my or { } // {
            lib = prev.my.lib or { } // import ./lib { pkgs = final; };
          };
        };
        json2nix = final: prev: {
          my = prev.my or { } // {
            json2nix = inputs.json2nix.packages."${prev.system}".default;
          };
        };
        rambo = final: prev: {
          my = prev.my or { } // {
            rambo = inputs.rambo.packages."${prev.system}".default;
          };
        };
      };
    };
}
