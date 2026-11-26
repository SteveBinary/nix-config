{
  lib,
  config,
  vars,
  ...
}:

let
  imageManifestDigest = "sha256:fc2422b68009a9e529306ec20adde488505c9eaabba10a2ab35eff381fabe8e8"; # 0.83.2
in
{
  sops.secrets.netbird-server-labels = {
    sopsFile = ./secrets.labels.enc;
    format = "binary";
    restartUnits = [ "docker-netbird-server.service" ];
  };
  sops.secrets.netbird-server-config = {
    sopsFile = ./secrets.config.enc;
    format = "binary";
    restartUnits = [ "docker-netbird-server.service" ];
  };

  virtualisation.oci-containers.containers."netbird-server" = {
    image = "docker.io/netbirdio/netbird-server@${imageManifestDigest}";
    volumes = [
      "${config.sops.secrets.netbird-server-config.path}:/etc/netbird/config.yaml:ro"
      "${vars.user.home}/docker/netbird-server:/var/lib/netbird:rw"
    ];
    networks = [
      "traefik"
    ];
    ports = [
      # UDP port 3478 is used by the STUN/TURN server to help devices discover each other
      # and establish direct peer-to-peer connections across NATs and firewalls
      "3478:3478/udp"
    ];
    cmd = [
      "--config"
      "/etc/netbird/config.yaml"
    ];
    labels = {
      # labels containing secrets are in secrets.labels.enc
      "traefik.enable" = "true";
      "traefik.http.routers.netbird-backend.entrypoints" = "websecure";
      "traefik.http.routers.netbird-backend.priority" = "100";
      "traefik.http.routers.netbird-backend.service" = "netbird-server";
      "traefik.http.routers.netbird-backend.tls" = "true";
      "traefik.http.routers.netbird-backend.tls.certresolver" = "letsencrypt";
      "traefik.http.routers.netbird-grpc.entrypoints" = "websecure";
      "traefik.http.routers.netbird-grpc.priority" = "100";
      "traefik.http.routers.netbird-grpc.service" = "netbird-server-h2c";
      "traefik.http.routers.netbird-grpc.tls" = "true";
      "traefik.http.routers.netbird-grpc.tls.certresolver" = "letsencrypt";
      "traefik.http.services.netbird-server-h2c.loadbalancer.server.port" = "80";
      "traefik.http.services.netbird-server-h2c.loadbalancer.server.scheme" = "h2c";
      "traefik.http.services.netbird-server.loadbalancer.server.port" = "80";
    };
    extraOptions = [
      "--label-file"
      "${config.sops.secrets.netbird-server-labels.path}"
    ];
  };

  # make sure the traefik network is available
  systemd.services."docker-netbird-server" = {
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
