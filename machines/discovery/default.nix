{ vars, ... }:

{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./services
    {
      home-manager.users."${vars.user.name}" = ./home.nix;
    }
  ];
}
