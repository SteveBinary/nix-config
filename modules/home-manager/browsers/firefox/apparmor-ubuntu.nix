{
  lib,
  config,
  ...
}:

# thanks to: https://discourse.nixos.org/t/home-manager-nixgl-wayland-persistent-duplicate-firefox-derivations-same-version/65380
# also, see: https://support.mozilla.org/en-US/kb/linux-security-warning

let
  cfg = config.my.browsers.firefox;
  scriptPath = "${config.home.homeDirectory}/.local/bin/setup-firefox-apparmor.sh";
in
{
  options.my.browsers.firefox = {
    enableAppArmorPreparationForUbuntu = lib.mkEnableOption "Enable measures to make the AppArmor setup for Firefox on Ubuntu easier";
  };

  config = {
    home.file."${scriptPath}" = lib.mkIf cfg.enableAppArmorPreparationForUbuntu {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        # See: https://support.mozilla.org/en-US/kb/linux-security-warning

        # The Firefox path is determined at Nix evaluation time and embedded here.
        # This ensures it's always the Nix store path, not a system-wide binary.
        FIREFOX_PATH="${config.programs.firefox.finalPackage}/bin/firefox"

        echo "Using Firefox path: $FIREFOX_PATH"

        # Ensure the directory exists
        sudo mkdir -p /etc/apparmor.d/

        # Write the AppArmor profile content
        sudo tee /etc/apparmor.d/firefox-nix > /dev/null << EOF
        # This profiles complements Firefox installed by Nix.
        # See: ${scriptPath}

        # This profile allows everything and only exists to give the
        # application a name instead of having the label "unconfined"
        abi <abi/4.0>,
        include <tunables/global>

        profile firefox-nix $FIREFOX_PATH flags=(unconfined) {
          userns,

          # Allow read access to the Nix store for Firefox and its dependencies
          /nix/store/** r,

          # Paths commonly needed for graphics drivers and other system components
          /run/opengl-driver/** r,              # Common on NixOS, might be needed on other distros if drivers are symlinked here
          /dev/dri/** rw,                       # Access to DRM devices for graphics
          /dev/shm/** rw,                       # Shared memory for IPC
          /etc/ssl/certs/ca-certificates.crt r, # Often needed for TLS/SSL

          # Site-specific See local/README for details.
          include if exists <local/firefox>
        }
        EOF

        # Reload AppArmor profiles
        sudo apparmor_parser -r /etc/apparmor.d/firefox-nix || true
        echo "Firefox AppArmor profile setup script completed."
        echo "You may need to restart Firefox for changes to take effect."
      '';
    };

    # Add activation script to provide instructions
    home.activation.firefoxAppArmorInstructions = lib.mkIf cfg.enableAppArmorPreparationForUbuntu (
      lib.hm.dag.entryAfter [ "writeBoundary" "installPackages" ] ''
        echo "======================================================================="
        echo "                    Firefox AppArmor Setup Required                    "
        echo "======================================================================="
        echo "To enable full Firefox security features (and remove the warning),"
        echo "you need to create an AppArmor profile. Home Manager has placed a "
        echo "script for this, which you can simply execute."
        echo "This requires root privileges (sudo)."
        echo ""
        echo "   ${scriptPath}"
        echo ""
        echo "After running the script, restart Firefox to see the changes."
        echo "======================================================================="
      ''
    );
  };
}
