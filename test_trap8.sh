#!/bin/bash
SCRIPT_NAME='"; echo "pwned'
# using double quotes for the trap argument to see if it interpolates vulnerability
trap "logger -t 'neos-$SCRIPT_NAME' 'CRITICAL'" ERR
false
