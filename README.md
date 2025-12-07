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
Each machine config also contains the respective Home Manager user config, if defined.

### modules/nixos

NixOS modules.

### modules/home-manager

Home Manger modules.

### home

Home Manager configurations for a standalone user config.

### overlays

Package overlays.

## Bootstrapping machines

### `orville`

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
   ```shell
   NIX_SSHOPTS="-i /home/steve/.ssh/id_orville_ed25519" nixos-rebuild switch \
     --flake .#orville \
     --target-host steve@<IP address of the remote host>
     --sudo --ask-sudo-password
   ```

### `discovery`

**Note:** The config sets a static IPv4 address and other network options.
Check that the IP address is not already in used in your network.
For step 4 you will need to use this IP address.

1. Build the SD card image: `nix build .#packages.aarch64-linux.discovery-sdcard-image`
   - You need to be capable of building for `aarch64-linux`, either by
     - building on a native `aarch64-linux` host,
     - building on a remote `aarch64-linux` machine, or
     - by having `aarch64-linux` emulation enabled on your build machine, typically via
       ```nix
       boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
       ```
   - The built image file will be `./result/sd-image/nixos-discovery-sdcard-aarch64-linux.img`
   - It contains the whole _final_ system and is **not** an installer.
     Because we can just flash the complete system image onto the SD card, there is no need for an installer.
2. Flash the image onto the SD card:\
   **IMPORTANT: `dd` will destroy your data! Triple check that you selected the right output device!!!**\
   Select your target device being flashed via `lsblk -f`, then replace the desired device (e.g. `/dev/sdb`) in the following command:
   ```shell
   sudo dd if=./result/sd-image/nixos-discovery-sdcard-aarch64-linux.img of=/dev/null bs=4096 conv=fsync status=progress
   ```
   This may take some minutes. Don't cancel the command!
3. Insert the SD card into the device and boot.
4. The setup is complete. To apply changes in the future, run the following command.
   ```shell
   NIX_SSHOPTS="-i /home/steve/.ssh/id_discovery_ed25519" \
     nixos-rebuild switch \
     --flake .#discovery \
     --target-host steve@<IP address of the remote host>
     --sudo --ask-sudo-password
   ```
