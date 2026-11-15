{ vars, ... }:

{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    {
      home-manager.users."${vars.user.name}" = ./home;
    }
  ];
}
