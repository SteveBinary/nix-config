{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.programs.development.kubernetes;
in
{
  options.my.programs.development.kubernetes = {
    enable = lib.mkEnableOption "Enable my Home Manager module for development with Kubernetes";
    setShellAliases = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kubecolor
      kubectl
      kubectx
      kubernetes-helm
      minikube
    ];

    home.shellAliases = lib.optionalAttrs cfg.setShellAliases {
      k = "kubecolor";
      kx = "kubectx";
      kn = "kubens";
      kd = "k describe";
      kg = "k get";
      kga = "k get all";
      kgp = "k get pods";
      kgs = "k get services";
      kgn = "k get networkpolicies";
      kds = ''sh -c 'kubectl get secret "$@" -o json | jq ".data | map_values(@base64d)"' _'';
    };
  };
}
