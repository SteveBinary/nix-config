# `aarch64-linux` Packages on `x86_64-linux` Ubuntu with Nix

There are basically two ways:

1. cross-compilation: faster, but might not work for every package
2. emulation: slower, but more compatible

Both are relatively easy with Nix, but this guide sets up `emulation` to achieve the best possible compatability.
At the end you can seamlessly build (and run!) `aarch64-linux` programs on a `x86_64-linux` Ubuntu host.

## Install Dependencies

```sh
sudo apt update
sudo apt install qemu-user-static binfmt-support
```

## Verify Installation

Look for `qemu-aarch64`:

```sh
ls /proc/sys/fs/binfmt_misc/
```

## Configure Nix

1. Add this to `/etc/nix/nix.conf`:
   ```
   extra-platforms = aarch64-linux
   ```
2. Restart the Nix deamon:
   ```sh
   sudo systemctl restart nix-daemon
   ```

## Verify complete Setup

You should be able to build `aarch64-linux` and `x86_64-linux` versions of packages:

```sh
nix build nixpkgs#legacyPackages.x86_64-linux.hello
nix build nixpkgs#legacyPackages.aarch64-linux.hello
```

And run them:

```sh
nix run nixpkgs#legacyPackages.x86_64-linux.hello
nix run nixpkgs#legacyPackages.aarch64-linux.hello
```
