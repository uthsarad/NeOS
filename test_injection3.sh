#!/bin/bash
set -euo pipefail
# Wait, why was there injection? Ah, the eval caused it BEFORE the trap was executed, because of the subshell in my eval!
# I need to see if bash itself expands $BASH_COMMAND maliciously DURING the trap execution.
trap 'err=$?; logger -t "neos-test" "CRITICAL: Script failed. Command: " "$BASH_COMMAND" "."; return $err 2>/dev/null' ERR
CMD='bad" $(date > /tmp/hacked_again)"'
$CMD
