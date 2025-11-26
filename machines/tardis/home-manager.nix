{
  vars,
  inputs,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${vars.user.name}" = ./home;
    extraSpecialArgs = {
      inherit vars;
    };
    sharedModules = [
      ../../modules/home-manager
      inputs.plasma-manager.homeModules.plasma-manager
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
