# NeOS default ~/.zshrc — zsh is the default shell for the live user and for
# accounts created by the installer, so ship a sane baseline. Without this
# file the first terminal in every session drops into zsh's new-user setup
# wizard instead of a prompt.

# History
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob
unsetopt beep nomatch
bindkey -e

# Completion
autoload -Uz compinit
compinit

# Prompt: [user@host dir]$
PS1='%B%F{blue}[%n@%m %1~]%$%f%b '

# Familiar helpers (mirror /etc/skel/.bashrc)
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lah'
