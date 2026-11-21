{ vars, ... }:

{
  imports = [
    ./configuration.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    {
      home-manager.users."${vars.user.name}" = ./home.nix;
    }
  ];
}
