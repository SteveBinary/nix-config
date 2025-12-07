{
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    mutableSettings = true; # change to false when the settings are moved here
  };

  networking.firewall.allowedUDPPorts = [
    53 # DNS
  ];
}
