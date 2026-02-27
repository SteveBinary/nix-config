{ pkgs }:

pkgs.writeShellApplication {
  name = "benchmark-cpu";

  runtimeInputs = with pkgs; [
    geekbench
    mprime
    sysbench

    coreutils
    systemd
  ];

  text = ''
    WARMUP_TIME=''${1:-15m}
    systemd-inhibit --who "Benchmark CPU" --why "benchmark" bash <<EOF
      {
        echo "================================================================================"
        echo "= warmup for $(printf "%-32s" "$WARMUP_TIME")                                  ="
        echo "================================================================================"
        timeout --preserve-status "$WARMUP_TIME" mprime -t
        # cleanup files created by mprime
        rm {prime.txt,mprime.pid,results.txt,results.bench.txt} 2&> /dev/null || true

        echo
        echo "================================================================================"
        echo "= running Geekbench 6                                                          ="
        echo "================================================================================"
        echo
        geekbench6 --cpu

        echo "================================================================================"
        echo "= running sysbench on all CPUs 3x for 2 minutes each                           ="
        echo "================================================================================"
        echo
        echo "= run 1 of sysbench ============================================================"
        echo
        sysbench --threads="$(nproc)" --time=120 cpu run
        echo "= run 2 of sysbench ============================================================"
        echo
        sysbench --threads="$(nproc)" --time=120 cpu run
        echo "= run 3 of sysbench ============================================================"
        echo
        sysbench --threads="$(nproc)" --time=120 cpu run

      } |& tee "benchmark-cpu__$(date +'%Y-%m-%d_%H-%M-%S').log"
    EOF
  '';
}
