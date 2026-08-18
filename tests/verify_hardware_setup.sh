#!/bin/bash
if [ ! -x "profile/airootfs/usr/local/bin/neos-hardware-setup" ]; then
    echo "Hardware setup script is not executable or missing."
    exit 1
fi
echo "Hardware setup script exists and is executable."
