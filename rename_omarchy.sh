#!/bin/bash
find profile/airootfs/ -depth -name "*omarchy*" -o -name "*Omarchy*" -o -name "*OMARCHY*" | while read -r item; do
  dir=$(dirname "$item")
  base=$(basename "$item")
  # replace Omarchy with NeOS
  newbase=$(echo "$base" | sed 's/Omarchy/NeOS/g; s/omarchy/neos/g; s/OMARCHY/NEOS/g')
  if [ "$base" != "$newbase" ]; then
    mv "$item" "$dir/$newbase"
  fi
done
