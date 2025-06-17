{ pkgs }:

# this function patches a desktop file of a given package without the need to rebuild the package itself
# based on https://www.reddit.com/r/NixOS/comments/scf0ui/comment/jpmhb6s
{
  pkg,
  appName,
  from,
  to,
}:

pkgs.lib.hiPrio (
  pkgs.runCommand "$patched-desktop-entry-for-${appName}" { } ''
    ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
    ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
  ''
)
