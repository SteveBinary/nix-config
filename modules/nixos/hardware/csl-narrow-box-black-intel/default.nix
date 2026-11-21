{
  pkgs,
  ...
}:

{
  config = {
    boot = {
      loader = {
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          configurationLimit = 30;
        };
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
      };
      kernel.sysctl."vm.swappiness" = 10;
    };

    ############################################
    # Intel Video Hardware Acceleration config #
    ############################################

    boot = {
      kernelModules = [ "kvm-intel" ];
      kernelParams = [ "i915.force_probe=46d1,i915.enable_guc=3" ];
    };

    hardware = {
      enableAllFirmware = true;
      intel-gpu-tools.enable = true;
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          libva-vdpau-driver
          intel-compute-runtime
          intel-ocl
          vpl-gpu-rt # QSV on 11th gen or newer
        ];
      };
    };

    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  };
}
