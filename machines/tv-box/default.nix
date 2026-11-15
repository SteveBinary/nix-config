{ vars, ... }:

{
  imports = [
    ./configuration.nix
    {
      home-manager.users."${vars.user.name}" = ./home.nix;
    }
  ];
}
