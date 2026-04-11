#!/bin/bash
trap 'echo "logger -t \"neos-\" \"CRITICAL: Command: \\\"$BASH_COMMAND\\\".\""' ERR
false
