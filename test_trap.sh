#!/bin/bash
trap 'echo "Command: \"$BASH_COMMAND\""' ERR
false
