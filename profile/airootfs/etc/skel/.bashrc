#
# ~/.bashrc
#

[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lah'

PS1='\[\e[1;34m\][\u@\h \W]\$\[\e[0m\] '

# Omarchy-derived NeOS shell environment (aliases, prompt, tool init), loaded
# only where it is installed at its expected path. The ISO currently carries it
# one level deeper (/usr/share/neos/neos/), and its EDITOR/BROWSER/MANPAGER rely
# on tools NeOS does not ship, so a stock install keeps the plain shell above
# (docs/architecture/OMARCHY_INTEGRATION.md). Previously this sourced
# "$NEOS_PATH/default/bash/rc" unconditionally and every interactive bash
# printed "/default/bash/rc: No such file or directory".
if [[ -r /usr/share/neos/default/bash/env-bootstrap && -r /usr/share/neos/default/bash/rc ]]; then
    source /usr/share/neos/default/bash/env-bootstrap
    source "$NEOS_PATH/default/bash/rc"
fi

# Add your own exports, aliases, and functions here.
