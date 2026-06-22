#
# ~/.bashrc
#

[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lah'

PS1='\[\e[1;34m\][\u@\h \W]\$\[\e[0m\] '

if [[ -f /run/archiso/bootmnt/neos/boot/x86_64/vmlinuz-linux-lts ]]; then
    echo ""
    echo "  Welcome to the NeOS Live Environment"
    echo "  To install: click 'Install NeOS' on your desktop"
    echo "  or run: neos-welcome"
    echo ""
fi
