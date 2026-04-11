#!/bin/bash
set -e
trap 'echo "Command: \"$BASH_COMMAND\""' ERR
cmd="hello\" > /tmp/pwned; #"
false
