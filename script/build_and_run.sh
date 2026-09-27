#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mode="${1:-run}"
case "$mode" in run|--verify|--logs|--telemetry|--debug|--build-only) ;; *) echo "Unknown mode: $mode" >&2; exit 2;; esac
pkill -x Auralis 2>/dev/null || true
./build.sh
bundle="$PWD/build/stage/Auralis.app"
if [[ "$mode" == --build-only ]]; then exit 0; fi
# Two process-tap mixers should not be active at the same time.
if pgrep -x Vorssaint >/dev/null; then
    echo "Auralis built. Quit Vorssaint before opening $bundle to test audio."
    exit 0
fi
if [[ "$mode" == --debug ]]; then
    lldb "$bundle/Contents/MacOS/Auralis"
else
    open -n "$bundle"
    case "$mode" in
      --verify) sleep 2; pgrep -x Auralis >/dev/null ;;
      --logs|--telemetry) /usr/bin/log stream --info --predicate 'process == "Auralis"' ;;
    esac
fi
