{
  # The default modules can be applied unconditionally, as they each expose 'enable' options.
  default = {
    imports = [
      ./common-utilities
      ./desktops
      ./gaming
      ./localization
      ./nix
      ./programs
      ./terminfo
      ./virtualisation
    ];
  };

  # Hardware modules are separate, because just importing them already applies their effects.
  # So they should be applied selectively.
  hardware-csl-narrow-box-black-intel = import ./hardware/csl-narrow-box-black-intel;
  hardware-framework-laptop-16-7040-amd = import ./hardware/framework-laptop-16-7040-amd;
  hardware-raspberry-pi-4 = import ./hardware/raspberry-pi-4;
  hardware-raspberry-pi-5 = import ./hardware/raspberry-pi-5;
}
