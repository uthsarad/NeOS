#!/bin/bash
set -euo pipefail
# With `trap '... " "$BASH_COMMAND" ...' ERR`, let's verify injection one more time
trap 'err=$?; logger -t "neos-test" "CRITICAL: Script failed. Command: " "$BASH_COMMAND" "."; return $err 2>/dev/null' ERR
eval 'foo"$(date > /tmp/hacked_again)"'
