#!/bin/bash
find profile/airootfs/ -type f | grep -vE '\.(ttf|png|pyc|jpg|svg)$' | while read -r f; do
  if grep -il "omarchy" "$f" >/dev/null; then
    sed -i 's/Omarchy/NeOS/g; s/omarchy/neos/g; s/OMARCHY/NEOS/g' "$f"
  fi
done
