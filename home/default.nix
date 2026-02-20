{ inputs }:

let
  mkHome =
    home: vars:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit (vars) system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };
      extraSpecialArgs = {
        inherit inputs vars;
        inherit (inputs.self) overlays;
      };
      modules = [
        (
          { inputs, ... }:
          {
            nix.registry = {
              nixpkgs.flake = inputs.nixpkgs;
              nixpkgs-stable.flake = inputs.nixpkgs-stable;
            };
            news.display = "silent";
            programs.home-manager.enable = true;
          }
        )
        home
        inputs.self.homeManagerModules.default
        inputs.plasma-manager.homeModules.plasma-manager
        inputs.sops-nix.homeManagerModules.sops
      ];
    };
in
{
  work = mkHome ./work rec {
    system = "x86_64-linux";
    user.name = builtins.getEnv "USER"; # requires '--impure' when doing 'home-manager switch'
    user.home = "/home/${user.name}";
  };
}
