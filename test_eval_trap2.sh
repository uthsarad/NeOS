#!/bin/bash
set -e
trap 'eval "echo Command: $BASH_COMMAND"' ERR
# Wait... the trap definition uses double quotes for $BASH_COMMAND, so they are delayed.
# Let's test the exact trap definition from the code, with a vulnerable bash command
