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

# this should all be tidied up a bit
function getGitBranch {
	echo "$(git branch 2>/dev/null | awk '/\* .+/ {print " (" $2 ")"}')"
}

function parse_git_branch {

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

function awesome_prompt {

	# Credit: https://gist.github.com/fzero/478cc0e41f16f8178e87

	local      BLACK="\[\033[0;30m\]"
	local  BLACKBOLD="\[\033[1;30m\]"
	local        RED="\[\033[0;31m\]"
	local    REDBOLD="\[\033[1;31m\]"
	local      GREEN="\[\033[0;32m\]"
	local  GREENBOLD="\[\033[1;32m\]"
	local     YELLOW="\[\033[0;33m\]"
	local YELLOWBOLD="\[\033[1;33m\]"
	local       BLUE="\[\033[0;34m\]"
	local   BLUEBOLD="\[\033[1;34m\]"
	local     PURPLE="\[\033[0;35m\]"
	local PURPLEBOLD="\[\033[1;35m\]"
	local       CYAN="\[\033[0;36m\]"
	local   CYANBOLD="\[\033[1;36m\]"
	local      WHITE="\[\033[0;37m\]"
	local  WHITEBOLD="\[\033[1;37m\]"

	parse_git_branch

	GIT_PART=""
	if [[ "$GIT_BRANCH" != "" ]]; then
		if [[ "$GIT_CLEAN" == "dirty" ]]; then
			GIT_BRANCH_COLOR=$YELLOWBOLD
		else
			GIT_BRANCH_COLOR=$GREENBOLD
		fi
		GIT_PART="$BLUEBOLD($GIT_BRANCH_COLOR$GIT_BRANCH$YELLOWBOLD$GIT_REMOTE$REDBOLD$GIT_UNTRACKED$BLUEBOLD)"
	fi

	HOSTPART="$CYANBOLD\u$GREENBOLD@$BLUEBOLD\h"
	MAINPART="$GREENBOLD\W$GIT_PART$WHITEBOLD\$$WHITE "

	export PS1="$HOSTPART $MAINPART"


}

export PROMPT_DIRTRIM=1
export PROMPT_COMMAND="awesome_prompt"
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

alias ll='ls -alh'
alias la='ls -A'
alias l='ls -CF'

alias ipy='ipython'
alias df='df -h'
alias ..='cd ..'
alias ...='cd ../..'
alias xclip='xclip -selection clipboard'

# git dotfiles repo alias setup
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

## Add anaconda3/bin to the path as fallback
export PATH="$PATH:/home/joshua/anaconda3/bin"
