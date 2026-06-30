#
# ~/.bashrc
#

[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lah'

PS1='\[\e[1;34m\][\u@\h \W]\$\[\e[0m\] '
