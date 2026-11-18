{ pkgs }:

pkgs.writeShellApplication {
  name = "hetzner-cost-optimized-availability-watcher";

  runtimeInputs = with pkgs; [
    alsa-utils
    hcloud
    jq
  ];

  text = ''
    INTERVAL=10
    TEST=false
    SERVER_TYPE="cx23"
    SERVER_LOCATION="fsn1"

    usage() {
      echo "Usage: hetzner-cost-optimized-watcher [--test] [SERVER_TYPE] [SERVER_LOCATION]"
      echo
      echo "Arguments:"
      echo "  SERVER_TYPE      Hetzner server type (default: cx23)"
      echo "  SERVER_LOCATION  Hetzner location (default: fsn1)"
      echo
      echo "Options:"
      echo "  --test           Simulate availability and play alert"
      echo
      echo "Required environment variable: HCLOUD_TOKEN"
    }

    # Parse arguments
    if [[ "''${1:-}" == "--test" ]]; then
      TEST=true
      shift
    fi

    if [[ $# -gt 2 ]]; then
      usage
      exit 1
    fi

    SERVER_TYPE="''${1:-$SERVER_TYPE}"
    SERVER_LOCATION="''${2:-$SERVER_LOCATION}"

    alert() {
      echo
      echo "!!! $SERVER_TYPE IN $SERVER_LOCATION AVAILABLE !!!"
      echo

      for _ in {1..5}; do
        speaker-test -t sine -f 880 -l 1 >/dev/null 2>&1 || true
        sleep 0.3
      done
    }

    if [[ "$TEST" == true ]]; then
      echo "TEST MODE: Simulating $SERVER_TYPE availability."
      alert
      exit 0
    fi

    echo "Watching Hetzner $SERVER_TYPE in $SERVER_LOCATION ..."
    echo "Checking every ''${INTERVAL}s. Press Ctrl+C to stop."
    echo

    while true; do
      if INFO=$(hcloud server-type describe "$SERVER_TYPE" -o json 2>/dev/null); then
        AVAILABLE=$(echo "$INFO" | jq -r --arg loc "$SERVER_LOCATION" '.locations[] | select(.name == $loc) | .available')

        if [[ "$AVAILABLE" == "true" ]]; then
          alert
        elif [[ "$AVAILABLE" == "false" ]]; then
          echo "[$(date +%T)] $SERVER_TYPE not available."
        else
          echo "[$(date +%T)] Location $SERVER_LOCATION not found in API response."
        fi
      else
        echo "[$(date +%T)] hcloud API error. Did you set HCLOUD_TOKEN?"
      fi

      sleep "$INTERVAL"
    done
  '';
}
