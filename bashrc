# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Write history file immediately after command is executed, before displaying
# Prompt again. This allows history to be saved between open terminal windows
export PROMPT_COMMAND='history -a'

# Default editor
export EDITOR="nano"

# Add home bin and user-installed python packages to path
PYBIN=$(python -c 'import site;import os; print "{}{}bin".format(site.getuserbase(), os.sep)');
export PATH="${PATH}:~/bin:${PYBIN}"

# Command shortcuts
alias xopen=xdg-open
alias highlightsyntax=pygmentize
alias syntax=pygmentize
alias mp3info=eyeD3
alias pt=pivotal_tools
alias bb=stash
alias bitbucket=stash

# Heler functions
code() { pygmentize $@; }
lcode() { code $@ | less -R; }
randpw(){ < /dev/urandom LC_ALL=c tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}
ctime() { date +%s; }
pause(){ read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'; }


#Alias for todo.sh, and setup bash completion for t alias
alias t='~/bin/todo.sh -d ~/.todo/config'
complete -F _todo t
export TODOTXT_DEFAULT_ACTION=ls


alias ll='ls -hlF'

# Setup AWS-cli command completion, if installed
#if [ -f "$(whereis -f aws_completer | cut -d ' ' -f2)" ]; then
#	complete -C "$(whereis -f aws_completer | cut -d ' ' -f2)" aws
#fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# See http://stackoverflow.com/questions/9457233/unlimited-bash-history
# Apparently, some bash commands may overwrite history file...
export HISTFILE=~/.bash_all_history
export HISTTIMEFORMAT="%a %b %d %Y %T "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi



#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]$(__git_ps1)\[\033[01;34m\]\[\033[00m\]\$ '

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
#alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# Mac OS/X fixes and stuff
if [[ "$OSTYPE" == "darwin"* ]]; then
	# Dumb os/x alias for __git_ps1.
	source "/usr/local/etc/bash_completion.d/git-completion.bash"
	source "/usr/local/etc/bash_completion.d/git-prompt.sh"

	# Put our homebrew path before our system path so we can override commands via Homebrew
	export PATH=$(echo $PATH | sed 's|/usr/local/bin||; s|/usr/local/sbin||; s|::|:|; s|^:||; s|\(.*\)|/usr/local/bin:/usr/local/sbin:\1|')
	
	export CLICOLOR=1
fi

# Source in site-specific, private variables (API keys and such)
[ -e ~/.bash_private ] && source ~/.bash_private;

