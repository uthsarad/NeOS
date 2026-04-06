#!/bin/bash
set -euo pipefail
trap 'err=$?; logger -t "neos-test" "CRITICAL: Script failed. Command: \"$BASH_COMMAND\""; return $err 2>/dev/null' ERR
CMD='bad" $(date > /tmp/hacked_again)"'
$CMD
