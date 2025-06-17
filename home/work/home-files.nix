{ config, ... }:

let
  preventSystemSuspendWhile =
    description: command:
    ''systemd-inhibit --who "${description}" --why "initiated by user" --what "idle:sleep:shutdown" --mode "block" \${"\n      "}/usr/bin/env zsh -c '${command}${"'"}'';
in
{
  home.file = {
    ".hushlogin".text = ""; # disable the login banner; also disables the warning "groups: cannot find name for group ID ..." because of LDAP

    "Projects/.directory".text = ''
      [Desktop Entry]
      Icon=folder-script
    '';

    "nix-config/.directory".text = ''
      [Desktop Entry]
      Icon=./assets/images/folder-nix-snowflake-light.svg
    '';

    "nix-config/justfile".text = ''
      set shell := ["zsh", "-cu"]

      @default:
          just --version
          just --list --unsorted

      # format all .nix files
      format:
          nix fmt --no-update-lock-file *.nix **/*.nix

      # make a Home Manager switch
      @switch:
          ${preventSystemSuspendWhile "Home Manager Switch" "home-manager --impure --log-format internal-json switch --flake {{ justfile_directory() }}#work |& nom --json"}

      # update the flake.lock
      update-flake:
          nix flake update --flake {{ justfile_directory() }}

      # update the desktop entries manually, because sometimes the Home Manager switch doesn't
      update-desktop-entries:
          sudo /usr/bin/update-desktop-database

      # update the flake.lock and apply by making a Home Manager switch
      update: update-flake switch

      # garbage collection of user packages
      collect-garbage:
          #!/usr/bin/env zsh
          before=$(df --human-readable --output=used / | sed 1d | sed "s/[[:space:]]*//")
          ${preventSystemSuspendWhile "Garbage Collection" "nix-collect-garbage"}
          after=$(df --human-readable --output=used / | sed 1d | sed "s/[[:space:]]*//")
          echo "=================================================="
          echo "Effect of garbage collection on disk usage"
          echo "  Before: $before"
          echo "  After:  $after"

      # garbage collection of home-manager generations and nix store optimise
      collect-garbage-all:
          #!/usr/bin/env zsh
          before=$(df --human-readable --output=used / | sed 1d | sed "s/[[:space:]]*//")
          ${preventSystemSuspendWhile "Garbage Collection (all)" "nix-collect-garbage -d"}
          ${preventSystemSuspendWhile "Nix Store Optimise" "nix store optimise"}
          after=$(df --human-readable --output=used / | sed 1d | sed "s/[[:space:]]*//")
          echo "=================================================="
          echo "Effect of garbage collection on disk usage"
          echo "  Before: $before"
          echo "  After:  $after"

      # list the Home Manager generations
      list-generations:
          home-manager generations
    '';
  };
}
