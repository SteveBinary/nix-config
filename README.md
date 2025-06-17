# nix-config

Configuration files for my NixOS machines and home configurations.

## Machine setup - for NixOS

1. Clone this repo into the home directory of a NixOS-system and change into it.
2. Run the following command when initially setting up the system:
   ```shell
   sudo nixos-rebuild switch --flake .#<<machine>>
   ```
3. If there is a `justfile` defined by the machine's user, it will be automatically created in the `nix-config` directory.
   It leverages [`just`](https://just.systems/man/en/) to define simple commands for doing NixOS housekeeping,
   like switching configurations and updating the system.

## Home Manager setup - for non-NixOS

1. Clone this repo into the home directory of a NixOS-system and change into it.
2. Run the following command when initially setting up Home Manager:
   ```shell
   nix run nixpkgs#home-manager -- switch --flake .#<<home config>> # --impure could be necessary
   ```
3. If there is a `justfile` defined by the user, it will be automatically created in the `nix-config` directory.
   It leverages [`just`](https://just.systems/man/en/) to define simple commands for doing Home Manager housekeeping,
   like switching configurations and updating the setup.

## Project structure

### lib

Utilities and helper functions.

### machines

Configurations and hardware configurations specific to the respective machine.

#### Bootstrapping `orville`

**Note:** The config sets a static IPv4 address and other network options.
Check that the IP address is not already in used in your network.
For step 4 you will need to use this IP address.

1. Run a graphical NixOS-installer image (the permissions/authentication can be a problem on the minimal ISOs).
2. Set a password for the `nixos` user via `passwd`.
3. Run the following command from the root of this repository and use the just created password when promted.
   **Note:** If there is already an existing `hardware-configuration.nix`, you don't need the corresponding options.
   ```shell
   nix run github:nix-community/nixos-anywhere -- \
     --flake .#orville \
     --build-on-remote \
     --generate-hardware-config \
     nixos-generate-config \
     machines/orville/hardware-configuration.nix \
     --target-host nixos@<IP address of the remote host>
   ```
4. The setup is complete. To apply changes in the future, run the following command.
   **Note:** You can use the user `steve` (and set `--use-remote-sudo`) instead of the `root` user but this will cause multiple password prompts.
   ```shell
   NIX_SSHOPTS="-i /home/steve/.ssh/id_ed25519_orville" nixos-rebuild switch \
     --flake .#orville \
     --target-host root@<IP address of the remote host>
   ```

### modules/nixos

NixOS modules.

### modules/home-manager

Home Manger modules.

### home/`<<user name>>`

Home Manager configuration for a specific user.
That's the place where to use the previously defined Home Manager modules of the applications.
