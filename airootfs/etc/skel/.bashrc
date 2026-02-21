#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

echo "Welcome to the NeOS Live Environment."
echo "To install via GUI, type: sudo calamares"
echo "To install via CLI, type: sudo archinstall"
