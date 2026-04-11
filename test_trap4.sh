#!/bin/bash
trap 'err=$?; logger -s -t "neos" "CRITICAL: Script failed at line $LINENO (Exit Code $err). Command: \"$BASH_COMMAND\". Please review the system journal."; return $err 2>/dev/null || true' ERR

ls "some string with $(echo vulnerable)" > /dev/null
