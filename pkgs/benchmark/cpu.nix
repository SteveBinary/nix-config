{ pkgs }:

pkgs.writeShellApplication {
  name = "benchmark-cpu";

  runtimeInputs = with pkgs; [
    geekbench
    mprime
    sysbench
  ];

  text = ''
    WARMUP_TIME=''${1:-15m}
    {
      echo "================================================================================"
      echo "= warmup for $(printf "%-32s" "$WARMUP_TIME")                                  ="
      echo "================================================================================"
      timeout --preserve-status "$WARMUP_TIME" mprime -t
      # cleanup files created by mprime
      rm {prime.txt,mprime.pid,results.bench.txt} 2&> /dev/null || true

      echo
      echo "================================================================================"
      echo "= running Geekbench 6                                                          ="
      echo "================================================================================"
      echo
      geekbench6 --cpu

      echo "================================================================================"
      echo "= running sysbench on all CPUs for 5 minutes                                   ="
      echo "================================================================================"
      echo
      sysbench --threads="$(nproc)" --time=300 cpu run
    } |& tee "benchmark-cpu__$(date +'%Y-%m-%d_%H-%M-%S').log"
  '';
}
