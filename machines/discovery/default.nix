{ vars, ... }:

{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./sdcard.nix
    ./services
    {
      home-manager.users."${vars.user.name}" = ./home.nix;
    }
  ];
}
