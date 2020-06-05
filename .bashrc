# My stuff {{{
[[ $- != *i* ]] && return # do nothing if not interactive

# turns off CTRL-S, because, why?
stty -ixon -ixoff

# set terminal mode to vi
set -o vi

# cypher log off
mesg n

# Add,,, bin(s),,, to path,,, h
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/bin:$PATH

# set ls defaults
alias ls='ls -F --color=auto'

# set color prompt
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Enable completion for stuff like git
# For some reason this isn't enabled by default on ~team?
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Set vim to user-installed neovim
# Otherwise, system-installed neovim
# And of course, $EDITOR can't be an alias,
# so we set editor to the binary and alias vim to that
USER_NEOVIM_BIN='~/bin/nvim.appimage'
SYS_NEOVIM_BIN=$(which nvim)
if [ -f "$USER_NEOVIM_BIN" ]; then
	export EDITOR="$USER_NEOVIM_BIN"
elif [ -f "$SYS_NEOVIM_BIN" ]; then
	export EDITOR="$SYS_NEOVIM_BIN"
fi
alias vim=$EDITOR

# }}}

# Aliases {{{

# Handy shortcut to view big folders
alias size='du --max-depth=1 -h | sort -h'

# }}}

# Functions {{{

# Directories {{{
# Inspiration: https://github.com/CosineP/dotfiles

# move to directory and list it
function cs() {
	cd "$@" && ls
}

# make directory and cd into it
function mkcd() {
	mkdir "$@" && cd "$@"
}

# End Directories }}}

# End Functions }}}

# Stuff from the defaults {{{
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
# }}}
