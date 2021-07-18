#  ____        ____  _                _
# |  _ \ _   _| __ )| | ___ _ __   __| |
# | |_) | | | |  _ \| |/ _ \ '_ \ / _` |
# |  __/| |_| | |_) | |  __/ | | | (_| |
# |_|    \__, |____/|_|\___|_| |_|\__,_|
#        |___/

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# +------------------------------------------
# | COLORS
# +------------------------------------------

   RED="\033[1;31m"
 GREEN="\033[1;32m"
YELLOW="\033[1;33m"
  BLUE="\033[1;34m"
PURPLE="\033[1;35m"
  CYAN="\033[1;36m"
 WHITE="\033[1;37m"
NORMAL="\033[0;39m"

ParseGitBranch() {

	# Credit: https://gist.github.com/fzero/478cc0e41f16f8178e87

	GIT_BRANCH=""
	GIT_UNTRACKED=""
	GIT_CLEAN=""
	GIT_REMOTE=""

	# ${IFS} ; IFS = Internal Field Separator
	local    branch_pattern="On branch ([^${IFS}]*)"
	local    remote_pattern="Your branch is (ahead|behind)"
	local     clean_pattern="working tree clean"
	local untracked_pattern="Untracked files"
	local   diverge_pattern="Your branch and (.*) have diverged"

	local git_status="$(git status 2> /dev/null)"

	# get branch
	if [[ ${git_status} =~ ${branch_pattern} ]]; then
		GIT_BRANCH="${BASH_REMATCH[1]}"
	fi

	# is dir clean
	if [[ ! ${git_status} =~ ${clean_pattern} ]]; then
		GIT_CLEAN="dirty"
	fi

	# are there untracked files
	if [[ ${git_status} =~ ${untracked_pattern} ]]; then
		GIT_UNTRACKED="+"
	fi

	# check if ahead/behind
	if [[ ${git_status} =~ ${remote_pattern} ]]; then
		if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
			GIT_REMOTE="↑"
		elif [[ ${BASH_REMATCH[1]} == "behind" ]]; then
			GIT_REMOTE="↓"
		fi
	fi

	# check if diverged
	if [[ ${git_status} =~ ${diverge_pattern} ]]; then
		GIT_REMOTE=":"
	fi

}

# echoing escaped color codes leads to unexpected bahaviour
# i.e. unexpected carriage return mid line after end of prompt

GitInfo() {
	ParseGitBranch
	GIT_PART=""
	if [[ "$GIT_BRANCH" != "" ]]; then
		if [[ "$GIT_CLEAN" == "dirty" ]]; then
			BRANCH_COLOR=$YELLOW
		else
			BRANCH_COLOR=$GREEN
		fi
		GIT_PART="$BLUE($BRANCH_COLOR$GIT_BRANCH$YELLOW$GIT_REMOTE$RED$GIT_UNTRACKED$BLUE)$WHITE"
	fi
}

# Hack functions to get PS1 to update

GitPre() {
	if [[ "$GIT_BRANCH" != "" ]]; then
		echo -n "("
	fi
}

GitClean() {
	if [[ "$GIT_BRANCH" != "" ]]; then
		if [[ "$GIT_CLEAN" != "dirty" ]]; then
			echo -n "$GIT_BRANCH"
		fi
	fi
}

GitDirty() {
	if [[ "$GIT_BRANCH" != "" ]]; then
		if [[ "$GIT_CLEAN" == "dirty" ]]; then
			echo -n "$GIT_BRANCH"
		fi
	fi
}

GitRemote() {
	echo -n "$GIT_REMOTE"
}

GitUntracked() {
	echo -n "$GIT_UNTRACKED"
}

GitPost() {
	if [[ "$GIT_BRANCH" != "" ]]; then
		echo -n ")"
	fi
}

Prompt() {
	# setup colors
	local K="\[\033[1;30m\]" # BLACK
	local R="\[\033[1;31m\]" # RED
	local G="\[\033[1;32m\]" # GREEN
	local Y="\[\033[1;33m\]" # YELLOW
	local B="\[\033[1;34m\]" # BLUE
	local P="\[\033[1;35m\]" # PURPLE
	local C="\[\033[1;36m\]" # CYAN
	local W="\[\033[1;37m\]" # WHITE
	local N="\[\033[0;39m\]" # NORMAL

	export PROMPT_COMMAND=""
	GIT_BIT="$B\$(GitPre)$G\$(GitClean)$Y\$(GitDirty)\$(GitRemote)$R\$(GitUntracked)$B\$(GitPost)"
	case "$1" in
		short)
			PS1="$W\$$N "
			;;
		dir)
			PS1="$G\W$W\$$N "
			;;
		block)
			export PROMPT_COMMAND="GitInfo"
			PS1="$B[$G\W$B$GIT_BIT$B]$W\$$N "
			;;
		*)
			export PROMPT_COMMAND="GitInfo"
			PS1="$C\u$G@$B\h $G\W$B\$(GitPre)$G\$(GitClean)$Y\$(GitDirty)\$(GitRemote)$R\$(GitUntracked)$B\$(GitPost)$W\$$N "
			;;
	esac
}

# +------------------------
# | Prompt ideas
# +------------------------
#
# Default: "user@host short_cwd(git)$ "
# Short  : "$ "
# Dir    : "short_cwd$ "
# Block  : "[short_cwd|git]$ "

export PROMPT_DIRTRIM=1
# export PS1="\[$CYAN\]\u\[$GREEN\]@\[$BLUE\]\h \[$GREEN\]\W\[$WHITE\]\$\[$NORMAL\] "
Prompt # Create default prompt
export PS2='> '
export PS4='+ '

# +----------------------------------------------------------------------------
# | ALIASES
# +----------------------------------------------------------------------------

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto --group-directories-first'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
else
	alias ls='ls --group-directories-first'
fi

alias ll='ls -Alh'
alias la='ls -A'
alias l='ls'

alias ipy='ipython'
alias df='df -h --total'
alias du='du -h -d 1'
alias ..='cd ..'
alias ...='cd ../..'
alias xclip='xclip -selection clipboard'

# git dotfiles repo alias setup
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

## Add anaconda3/bin to the path as fallback
export PATH="$PATH:$HOME/anaconda3/bin"
