{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        port = 1883;
        users = {
          beekeeper-sensor-gateway = {
            acl = [
              "write msh/EU_868/beekeepers/#"
            ];
            # nix shell nixpkgs#mosquitto --command mosquitto_passwd -c /tmp/passwd beekeeper-sensor-gateway
            hashedPassword = "$7$1000$c0X/Nb0h0X+8r60qnBlMHOL4CVhpFLz75GRYCzfyTmoPySaSeZEiYFM6gHcUmLIXWvVGNrX7jgsDY0BYxLYhkQ==$sAItTrzm99cScp2cSr3AB4jil/QP0pQA2WFXBYczMz8sSuAok1yzESGe6dkue1HXJTQo/Tqkz+z4H6jtDoH6LA==";
          };
          beekeeper-admin = {
            acl = [
              "readwrite msh/EU_868/beekeepers/#"
            ];
            # nix shell nixpkgs#mosquitto --command mosquitto_passwd -c /tmp/passwd beekeeper-admin
            hashedPassword = "$7$1000$+r68R+LYFMyCCq4og11ApmqzY6ooFN5E33MrQJIR4xscBwutcvgbT9q1WJ28Mm0xxyRDCeXZz4UE6UpH/VzzQg==$hoS/4WpHC1zMIGbTiKW6GxgQzS6jYjoF1uv1pb0yGJBdx2QNFTasnas7ZOFXiNHCtud5Yij0+lfphSrrGO9fSw==";
          };
        };
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [
    1883
  ];
}
