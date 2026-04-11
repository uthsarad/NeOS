#!/bin/bash
rm -f /tmp/pwned1
trap 'echo "Command: \"$BASH_COMMAND\""' ERR
ls "$(touch /tmp/pwned1; echo 'vuln')" > /dev/null
