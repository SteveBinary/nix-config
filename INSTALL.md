# Full NixOS via `nixos-anywhere`

[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) can install NixOS remotely on any Linux System.
The target system can be a standard Linux like Ubuntu or it could be just booted into the NixOS install image.

Example parameters when the target system is booted into the NixOS installer:
- `NIXOS_CONFIG`: e.g. `.#tv-box`
- `TARGET_HOST`: e.g. `nixos@192.168.178.115` -> on the booted installer, set a password for user `nixos` with `passwd`
- `PATH_TO_HARDWARE_CONFIG`: e.g. `./machines/tv-box/hardware-configuration.nix`
- optional: `--build-on remote` is recommended for powerful-enough targets, saves uploading from your machine to the target, i.e. don't set it for a Raspberry Pi
- optional: `-i ~/.ssh/<PRIVATE-SSH-KEY-FILE>` set which SSH key to use for accessing the target system

```sh
nix run nixpkgs#nixos-anywhere -- \
   --flake .#<NIXOS_CONFIG> \
   --target-host <TARGET_HOST>  \
   --build-on remote \
   --generate-hardware-config nixos-generate-config <PATH_TO_HARDWARE_CONFIG>
```

## Hetzner virtual Server

Create a virtual server with the Ubuntu image and make sure you have access to root via an SSH key.

Note, that `--kexec-extra-flags "-c"` needs to be added to the `nixos-anywhere` command at time of writing.\
See: https://github.com/nix-community/nixos-anywhere/issues/651#issuecomment-5098973977
