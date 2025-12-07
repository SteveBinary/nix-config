{
  config,
  vars,
  ...
}:

let
  preventSystemSuspendWhile =
    description: command:
    ''systemd-inhibit --who "${description}" --why "initiated by user" --what "idle:sleep:shutdown" --mode "block" \${"\n      "}/usr/bin/env zsh -c '${command}${"'"}'';
in
{
  home.file = {
    "Projects/.directory".text = ''
      [Desktop Entry]
      Icon=folder-script
    '';

    "nix-config/.directory".text = ''
      [Desktop Entry]
      Icon=./assets/images/folder-nix-snowflake-light.svg
    '';

    "Nextcloud/.directory".text = ''
      [Desktop Entry]
      Icon=${config.home.homeDirectory}/nix-config/assets/images/folder-nextcloud-light.svg
    '';

    "nix-config/justfile".text = ''
      set shell := ["zsh", "-cu"]

      @default:
          just --version
          just --list --unsorted

      # format all .nix files
      format:
          nix fmt --no-update-lock-file *.nix **/*.nix

      # make a system switch
      @switch:
          ${preventSystemSuspendWhile "NixOS Switch" "sudo nixos-rebuild --verbose --log-format internal-json switch --flake {{ justfile_directory() }}#${vars.machine} |& nom --json"}

      # make a system switch for a remote machine; the `machine` must have an SSH key at ~/.ssh/id_`machine`_ed25519 and an entry in ~/.ssh/config with its real hostname / IP address
      @remote-switch machine:
          ${preventSystemSuspendWhile "NixOS Remote Switch" ''
            NIX_SSHOPTS="-i /home/steve/.ssh/id_{{ machine }}_ed25519" \
                        nixos-rebuild switch \
                        --flake {{ justfile_directory() }}#{{ machine }} \
                        --target-host steve@{{ machine }} \
                        --sudo --ask-sudo-password''}

      # update the flake.lock
      update-flake:
          sudo nix flake update --flake {{ justfile_directory() }}

      # update the flake.lock and apply by making a system switch
      update: update-flake switch

      # garbage collection of system packages
      collect-garbage:
          #!/usr/bin/env zsh
          before=$(df --human-readable --output=used / | sed 1d | sed "s/[[:space:]]*//")
          ${preventSystemSuspendWhile "Garbage Collection" "sudo nix-collect-garbage"}
          after=$(df --human-readable --output=used / | sed 1d | sed "s/[[:space:]]*//")
          echo "=================================================="
          echo "Effect of garbage collection on disk usage"
          echo "  Before: $before"
          echo "  After:  $after"

      # garbage collection of home-manager + system generations and nix store optimise
      collect-garbage-all:
          #!/usr/bin/env zsh
          before=$(df --human-readable --output=used / | sed 1d | sed "s/[[:space:]]*//")
          # easy way to temporarily get sudo rights so the user won't be asked later
          sudo echo -n
          ${preventSystemSuspendWhile "Garbage Collection (user)" "nix-collect-garbage -d"}
          ${preventSystemSuspendWhile "Garbage Collection (system)" "sudo nix-collect-garbage -d"}
          ${preventSystemSuspendWhile "Nix Store Optimisation" "nix store optimise"}
          after=$(df --human-readable --output=used / | sed 1d | sed "s/[[:space:]]*//")
          echo "=================================================="
          echo "Effect of garbage collection on disk usage"
          echo "  Before: $before"
          echo "  After:  $after"

      # list the system generations (from the boot menu), not the home-manager generations
      list-generations:
          sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    '';
  };
}
