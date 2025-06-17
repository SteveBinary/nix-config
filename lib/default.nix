{ pkgs }:

{
  stringUtils = import ./stringUtils.nix { inherit pkgs; };
  patchDesktopFile = import ./patchDesktopFile.nix { inherit pkgs; };
}
