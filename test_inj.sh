#!/bin/bash
trap 'echo "Command: \"$BASH_COMMAND\""' ERR
cmd="hello\" > /tmp/pwned; #"
eval "$cmd" || true
