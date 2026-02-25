{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.my.misc.benchmarking;

  benchmark-cpu = pkgs.writeShellApplication {
    name = "benchmark-cpu";

    runtimeInputs = with pkgs; [
      geekbench
      mprime
      sysbench
    ];

    text = ''
      echo "======================================================================"
      echo "= warmup for 15 minutes                                              ="
      echo "======================================================================"
      timeout 15m mprime -t

      echo "======================================================================"
      echo "= running sysbench on all CPUs for 2 minutes                         ="
      echo "======================================================================"
      sysbench --threads="$(nproc)" --time=120 cpu run

      echo "======================================================================"
      echo "= running Geekbench 6                                                ="
      echo "======================================================================"
      geekbench6
    '';
  };
in
{
  options.my.misc.benchmarking = {
    enable = lib.mkEnableOption "Install benchmarking tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      benchmark-cpu
    ];
  };
}
