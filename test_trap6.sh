#!/bin/bash
trap 'logger -t "neos" "CRITICAL: Command: \"$BASH_COMMAND\"."' ERR
ls "$(echo hello)" > /dev/null
