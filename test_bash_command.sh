#!/bin/bash
set -e
trap 'echo "Command was: $BASH_COMMAND"' ERR
eval "echo \"hello\""
eval "false"
