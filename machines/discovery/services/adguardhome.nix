{
  services.adguardhome = {
    enable = true;
    openFirewall = true; # only opens ports for the web interface
    mutableSettings = true; # change to false when the settings are moved here
  };

  networking.firewall.allowedUDPPorts = [
    53 # DNS
  ];
}
