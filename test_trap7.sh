#!/bin/bash
SCRIPT_NAME='"; echo "pwned'
trap 'logger -t "neos-$SCRIPT_NAME" "CRITICAL"' ERR
false
