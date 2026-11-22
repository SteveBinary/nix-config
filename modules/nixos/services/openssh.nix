{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.services.openssh;
in
{
  options.my.services.openssh = {
    enable = lib.mkEnableOption "Enable my configuration for the OpenSSH server with hardened settings";
    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
    };
    allowedUser = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
        ports = lib.mkForce [ cfg.port ];
        settings = {
          Banner = pkgs.my.lib.sshBanner config.networking.hostName;

          AllowUsers = [ cfg.allowedUser ];
          AuthenticationMethods = "publickey";
          KbdInteractiveAuthentication = false;
          PubkeyAuthentication = "yes";
          PasswordAuthentication = false;
          PermitEmptyPasswords = "no";
          PermitRootLogin = "no";

          LoginGraceTime = 30;
          MaxAuthTries = 3;
          MaxSessions = 3;

          AllowAgentForwarding = "no";
          AllowTcpForwarding = "no";
          ClientAliveCountMax = 2;
          X11Forwarding = false;
        };
      };
    };
  };
}
