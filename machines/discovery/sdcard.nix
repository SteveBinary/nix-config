{
  pkgs,
  inputs,
  vars,
  ...
}:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  sdImage.compressImage = false;
  image.baseName = "nixos-${vars.machine}-sdcard-${pkgs.stdenv.hostPlatform.system}";
}
