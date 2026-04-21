#!/bin/bash
set -e
SCRIPT_NAME='test";id;"'
trap 'echo "Error: $SCRIPT_NAME"' ERR
false
