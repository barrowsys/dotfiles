# Discussion: is there a more proper way to run stuff only if interactive? like .bash_profile or something?
[[ $- != *i* ]] && return # do nothing if not interactive

# Terminal Settings {{{

# turns off CTRL-S, because, why?
stty -ixon -ixoff

# set terminal editing mode to vi
set -o vi

# make "**" in paths work
shopt -s globstar

# cypher log off
mesg n

# set color prompt
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# History Settings {{{

# Append to the history file and never clear it
shopt -s histappend
HISTSIZE=-1
HISTFILESIZE=-1
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# }}}

# }}}

# Path {{{

export PATH=$HOME/bin:$HOME/.local/bin:$PATH

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

# displays the total size of all folders in the working directory, sorted small -> large
alias size='du --max-depth=1 -h | sort -h'

# ls defaults
alias ls='ls --color=auto'

# }}}

# Functions {{{

# Directories {{{
# Inspiration: https://github.com/CosineP/dotfiles

# move to directory and list it
# Discussion: would it be so bad to alias cd to this?
function cs() {
	cd "$@" && ls
}

# make directory and cd into it
function mkcd() {
	mkdir "$@" && cd "$@"
}

# }}}

# }}}

# Misc {{{

# Enable completion for stuff like git
# For some reason this isn't enabled by default on ~team?
# This is a black box yoinked out of the defaults
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# }}}
