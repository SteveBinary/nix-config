{ pkgs }:

# Recursively find all `.nix` files under `dir` and import them into a nested attrset based on their relative path.
# For example:
#
# config/
# ├── settings.nix
# ├── foo/
# │   ├── bar.nix
# │   └── baz/
# │       └── qux.nix
# └── other/
#     └── thing.nix
#
# becomes:
#
# {
#   settings = ./config/settings.nix;
#   foo.bar = import ./config/foo/bar.nix;
#   foo.baz.qux = import ./config/foo/baz/qux.nix;
#   other.thing = import ./config/other/thing.nix;
# }

dir:

let
  lib = pkgs.lib;
  files = lib.fileset.toList (lib.fileset.fileFilter (file: file.hasExt "nix") dir);

  pathToAttrs =
    file:
    let
      relative = lib.path.removePrefix dir file;
      pathComponents = lib.path.subpath.components (builtins.toString relative);
      fileName = lib.last pathComponents;
      name = lib.removeSuffix ".${lib.last (lib.splitString "." fileName)}" fileName;
      parents = lib.init pathComponents;
    in
    lib.foldr (part: acc: { ${part} = acc; }) { ${name} = import file; } parents;

in
lib.foldr lib.recursiveUpdate { } (map pathToAttrs files)
