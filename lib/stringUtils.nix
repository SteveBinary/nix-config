{ pkgs }:

{
  upperCaseFirstLetter =
    value: (pkgs.lib.toUpper (pkgs.lib.substring 0 1 value)) + (pkgs.lib.substring 1 (-1) value);
}
