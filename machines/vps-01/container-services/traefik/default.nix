{
  config,
  lib,
  vars,
  ...
}:

let
  imageManifestDigest = "sha256:2e288bd466b23d4c62a76c89ddddb2965798b7a3f925aaa4400982b5028e7f92"; # v3.8.0
in
{
  virtualisation.oci-containers.containers."traefik" = {
    image = "docker.io/traefik@${imageManifestDigest}";
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock:ro"
      "${vars.user.home}/docker/traefik/letsencrypt:/letsencrypt:rw"
    ];
    networks = [
      "traefik"
    ];
    ports = [
      "80:80/tcp"
      "443:443/tcp"
    ];
    cmd = [
      # logging
      "--log.level=INFO"
      "--accesslog=true"
      # Docker provider
      "--providers.docker=true"
      "--providers.docker.exposedbydefault=false"
      "--providers.docker.network=traefik"
      # entrypoints
      "--entrypoints.web.address=:80"
      "--entrypoints.websecure.address=:443"
      "--entrypoints.websecure.allowACMEByPass=true"
      "--entrypoints.web.http.aliasHeadersStrategy=delete"
      "--entrypoints.websecure.http.aliasHeadersStrategy=delete"
      # disable timeouts for long-lived gRPC streams
      "--entrypoints.websecure.transport.respondingTimeouts.readTimeout=0"
      "--entrypoints.websecure.transport.respondingTimeouts.writeTimeout=0"
      "--entrypoints.websecure.transport.respondingTimeouts.idleTimeout=0"
      # HTTP to HTTPS redirect
      "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      # Let's Encrypt ACME
      "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
      # gRPC transport settings
      "--serverstransport.forwardingtimeouts.responseheadertimeout=0s"
      "--serverstransport.forwardingtimeouts.idleconntimeout=0s"
    ];
    extraOptions = [
      # stable IP address so that the server has a single trusted proxy
      "--ip=172.30.0.10"
    ];
  };

  # make sure the traefik network is available
  systemd.services."docker-traefik" = {
    serviceConfig = {
      Restart = lib.mkForce "on-failure";
      RestartMaxDelaySec = lib.mkForce "1m";
      RestartSec = lib.mkForce "100ms";
      RestartSteps = lib.mkForce 9;
    };
    after = [
      "docker-network-traefik.service"
    ];
    requires = [
      "docker-network-traefik.service"
    ];
  };

  # set up the traefik network
  systemd.services."docker-network-traefik" = {
    unitConfig.Description = "Docker network for traefik";
    path = [ config.virtualisation.docker.package ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f traefik";
    };
    script = ''
      docker network inspect traefik || docker network create traefik --driver=bridge --subnet=172.30.0.0/24 --gateway=172.30.0.1
    '';
  };
}
