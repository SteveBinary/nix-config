{
  lib,
  config,
  ...
}:

let
  imageManifestDigest = "sha256:858f129a297c493abea2230c073456726c1a0c564d1b1d804438d104037b1ef2"; # v2.99.0
in
{
  sops.secrets.netbird-dashboard-environment = {
    sopsFile = ./secrets.environment.enc;
    format = "binary";
    restartUnits = [ "docker-netbird-dashboard.service" ];
  };
  sops.secrets.netbird-dashboard-labels = {
    sopsFile = ./secrets.labels.enc;
    format = "binary";
    restartUnits = [ "docker-netbird-dashboard.service" ];
  };

  virtualisation.oci-containers.containers."netbird-dashboard" = {
    image = "docker.io/netbirdio/dashboard@${imageManifestDigest}";
    networks = [
      "traefik"
    ];
    environmentFiles = [
      config.sops.secrets.netbird-dashboard-environment.path
    ];
    labels = {
      # labels containing secrets are in secrets.labels.enc
      "traefik.enable" = "true";
      "traefik.http.routers.netbird-dashboard.entrypoints" = "websecure";
      "traefik.http.routers.netbird-dashboard.priority" = "1";
      "traefik.http.routers.netbird-dashboard.service" = "dashboard";
      "traefik.http.routers.netbird-dashboard.tls" = "true";
      "traefik.http.routers.netbird-dashboard.tls.certresolver" = "letsencrypt";
      "traefik.http.services.dashboard.loadbalancer.server.port" = "80";
    };
    extraOptions = [
      "--label-file"
      "${config.sops.secrets.netbird-dashboard-labels.path}"
    ];
  };

  # make sure the traefik network is available
  systemd.services."docker-netbird-dashboard" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-traefik.service"
    ];
    requires = [
      "docker-network-traefik.service"
    ];
  };
}
