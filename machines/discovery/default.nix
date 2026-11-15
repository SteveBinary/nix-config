{ vars, ... }:

{
  imports = [
    ./configuration.nix
    ./services
    {
      home-manager.users."${vars.user.name}" = ./home.nix;
    }
  ];
}
