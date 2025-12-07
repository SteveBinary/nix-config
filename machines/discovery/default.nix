{ vars, ... }:

{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./sdcard.nix
    {
      home-manager.users."${vars.user.name}" = ./home.nix;
    }
  ];
}
