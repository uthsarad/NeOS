# NeOS environment (NEOS_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/neos/default/bash/env-bootstrap ]] && source /usr/share/neos/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default NeOS aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$NEOS_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
