#!/bin/bash
set -euo pipefail
# Sentinel: [task] Verify that the trap command does not inadvertently mask script exit codes. Ensure that evaluating $0 or other variables within the trap does not introduce arbitrary command execution risks if manipulated by an attacker.
# Bolt: [task] Ensure the logging mechanism avoids excessive subshell overhead where possible, relying on native variables like $LINENO.
# Palette: [task] Ensure the format of the logged error message is clear, searchable in the system journal, and accurately represents a critical script failure to aid developers and administrators.
trap 'logger -t neos-$(basename "$0") "ERROR: Script failed at line $LINENO"' ERR
# neos-installer-partition placeholder