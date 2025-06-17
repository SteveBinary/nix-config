{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  cfg = config.my.nix;
in
{
  options.my.nix = {
    enable = lib.mkEnableOption "Enable my configuration for Nix";
    trusted-users = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      package = pkgs.nixVersions.latest;
      # TODO: this leads to a conflict on orville
      #registry = {
      #  nixpkgs.flake = inputs.nixpkgs;
      #  nixpkgs-stable.flake = inputs.nixpkgs-stable;
      #};
      channel.enable = false; # remove nix-channel related tools & configs, as flakes are used for everything
      settings = {
        warn-dirty = false;
        experimental-features = [
          "flakes"
          "nix-command"
        ];
        trusted-users = cfg.trusted-users;
      };
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
  };
}
