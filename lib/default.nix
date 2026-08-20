{ pkgs }:

{
  merge = import ./merge.nix { inherit pkgs; };
  patchDesktopFile = import ./patchDesktopFile.nix { inherit pkgs; };
  stringUtils = import ./stringUtils.nix { inherit pkgs; };
}
