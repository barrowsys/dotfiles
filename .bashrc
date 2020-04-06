# My stuff {{{
stty -ixon -ixoff # turns off CTRL-S, because, why?
[[ $- != *i* ]] && return # do nothing if not interactive

# set vim as editor and set terminal mode to vi
export EDITOR=vim
set -o vi

# cypher log off
mesg n

# rust path entries
export PATH=~/.cargo/bin:$PATH
export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/src

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

# }}}

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
