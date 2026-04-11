#!/bin/bash
trap 'echo -e "Command: \"$BASH_COMMAND\""' ERR
ls "$(echo hello)" > /dev/null
