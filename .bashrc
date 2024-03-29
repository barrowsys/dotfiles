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

export PATH=$HOME/bin:$HOME/.local/bin:$HOME/Apps/arduino/bin:$PATH
export STAGING_DIR="/home/barrow/Documents/openwrt/staging_dir"
# export PATH="/home/barrow/Documents/openwrt/staging_dir/toolchain-mips_24kc_gcc-8.4.0_musl/bin:$PATH"

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
alias hr='numfmt --to=iec --suffix=B'

# ls defaults
alias ls='ls --color=auto'

# Fullscreen vim help
alias vimdoc='vim -c :Help'

# todo.sh config
export TODOTXT_DEFAULT_ACTION=ls
alias t='todo.sh'

# Useful alias for building rust projects
alias cargow='cargo watch -x "check --all-targets --all-features" -x "build --all-targets --all-features" -x "clippy -Z unstable-options --all-targets --all-features -- -D warnings"'
alias cargowf='cargo watch -x "check --all-targets --all-features" -x "build --all-targets --all-features" -x "clippy -Z unstable-options --all-targets --all-features -- -D warnings" -x "fmt"'
alias cargowft='cargo watch -x "check --all-targets --all-features" -x "build --all-targets --all-features" -x "clippy -Z unstable-options --all-targets --all-features -- -D warnings" -x "fmt" -x "test --all-features"'
alias cargowftd='cargo watch -x "check --all-targets --all-features" -x "build --all-targets --all-features" -x "clippy -Z unstable-options --all-targets --all-features -- -D warnings" -x "fmt" -x "test --all-features" -x "doc --all-features"'
alias cargowfdt='cargo watch -x "check --all-targets --all-features" -x "build --all-targets --all-features" -x "clippy -Z unstable-options --all-targets --all-features -- -D warnings" -x "fmt" -x "doc --all-features" -x "test --all-features"'

# }}}

# Functions {{{

function autoclick() {
	local seconds="${1:-30}"
	local cps="${2:-80}"
	local delay=$((1000 / cps))
	local clicks=$((seconds * cps))
	# echo Seconds $seconds Delay $delay Clicks $clicks
	xdotool click --delay $delay --repeat $clicks 1
}

	# FD Pipes {{{
		# mkfd 9
		# mkfd 10
		# cat test1 >&9
		# cat test2 >&10
		# difffd 9 10
		function mkfd {
			# use a fifo
			# FD_FILE=`mktemp -u`
			# mkfifo $FD_FILE

			# use a regular file
			FD_FILE=`mktemp`

			export FD$1=$FD_FILE
			eval "exec $1<>$FD_FILE"
		}
		function fd {
			echo "/dev/fd/$1"
		}
		function difffd {
			diff ${@:1:$#-2} "/dev/fd/${@: -2:1}" "/dev/fd/${@: -1:1}"
		}
	# End FD Pipes }}}

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

# ip shorthands {{{
# because sometimes i just want All the information
# set the env variable $WORKING_IFACE to avoid retyping its name
# to show a full list of all devices while $WORKING_IFACE is set, pass -a

# common code
function _ip_impl() {
	if [[ "$@" ]]; then
		if [[ "$@" == "-a" ]]; then
			# "ipa -a" should be the full list, even if $WORKING_IFACE is set.
			ip $ip_command
		else
			# "ipa arg" should be "ip address show dev arg"
			ip $ip_command dev "$@"
		fi
	elif [[ "$WORKING_IFACE" ]]; then
		# if $WORKING_IFACE is set and no argument is passed,
		# check if $WORKING_IFACE exists. If yes, run the command on it.
		# If no, output a custom error message.
		if ip link show "$WORKING_IFACE" &>/dev/null; then
			ip $ip_command dev "$WORKING_IFACE"
		else
			echo "Device \"$WORKING_IFACE\" (\$WORKING_IFACE) does not exist."
			echo "Did you mean to use -a?"
		fi
	else
		# If $WORKING_IFACE is not set and no argument is passed,
		# run the default full list
		ip $ip_command
	fi
}

# show net addresses
function ipa() {
	local ip_command="addr show"
	_ip_impl $@
}

# show net links
function ipl() {
	local ip_command="link show"
	_ip_impl $@
}

# show net routes
function ipr() {
	local ip_command="route list"
	_ip_impl $@
}

# show net neighbors
function ipn() {
	local ip_command="neigh show"
	_ip_impl $@
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

if [[ "$TERM" == "xterm-kitty" ]]; then
	# neofetch --kitty --source '/home/barrow/Pictures/profile pics/bill cypher banner.png'
	alias NEOFETCH='neofetch --kitty --source "/home/barrow/Pictures/neofetch images/"'
	neofetch --kitty --source '/home/barrow/Pictures/neofetch images/'
	# neofetch --kitty --source '/home/barrow/Pictures/most important images/daily affirmations/'
fi
