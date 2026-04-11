#!/bin/bash
set -e
trap 'err=$?; echo -e "🚨 CRITICAL ERROR\nCommand: \"$BASH_COMMAND\"" >&2; logger -t "neos" "CRITICAL: Command: \"$BASH_COMMAND\"."; return $err 2>/dev/null || true' ERR

ls 'vuln"; echo "pwned' >/dev/null
