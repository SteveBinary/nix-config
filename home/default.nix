{ inputs }:

let
  mkHome =
    home: vars:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${vars.system};
      extraSpecialArgs = {
        inherit inputs vars;
        inherit (inputs.self) overlays;
      };
      modules = [
        home
        ../modules/home-manager
        inputs.sops-nix.homeManagerModules.sops
        inputs.plasma-manager.homeModules.plasma-manager
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
