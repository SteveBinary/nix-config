{
  lib,
  config,
  ...
}:

let
  cfg = config.my.misc.virt-manager-extra;
in
{
  options.my.misc.virt-manager-extra = {
    enable = lib.mkEnableOption "Enable my Home Manager module for virt-manager-extra";
  };

  config = lib.mkIf cfg.enable {
    # actually enabling virt-manager and virtualisation.libvirtd is done in the machine's configuration
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };
}
