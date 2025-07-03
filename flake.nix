{
  description = "Modular flake-based nix-config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    rambo = {
      url = "github:SteveBinary/rambo";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, ... }:
    {
      nixosConfigurations = {
        tardis = inputs.nixpkgs.lib.nixosSystem (
          let
            vars = {
              machine = "tardis";
              user.name = "steve";
              user.home = "/home/${vars.user.name}";
              myLib = pkgs: import ./lib { inherit pkgs; };
            };
          in
          rec {
            specialArgs = { inherit inputs vars; };
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
                  inputs.plasma-manager.homeManagerModules.plasma-manager
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
            system = "x86_64-linux";
            user.name = builtins.getEnv "USER"; # requires '--impure' when doing 'home-manager switch'
            user.home = "/home/${user.name}";
            pkgs = inputs.nixpkgs.legacyPackages.${system};
            myLib = import ./lib { inherit pkgs; };
          in
          {
            inherit pkgs;
            extraSpecialArgs = { inherit inputs myLib; };
            modules = [
              {
                home.username = user.name;
                home.homeDirectory = user.home;
              }
              ./home/work
              ./modules/home-manager
              inputs.sops-nix.homeManagerModules.sops
              inputs.plasma-manager.homeManagerModules.plasma-manager
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
    );
}
