{
  # Some configs were originally generated via the Netbird install script and translated to Nix via compose2nix.

  imports = [
    ./netbird-dashboard
    ./netbird-server
    ./traefik
  ];
}
