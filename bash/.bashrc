# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

export EDITOR="/usr/bin/vim"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
export LANGUAGE=en_US:en

# append to the history file, don't overwrite it
shopt -s histappend

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
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

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

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
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

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
source ~/.bash_completion.d/complete_alias
source ~/.inputrc

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias mvn11='JAVA_HOME=/usr/lib/jvm/jdk-11.0.24+8 mvn'
alias mvn17='JAVA_HOME=/usr/lib/jvm/jdk-17.0.12+7 mvn'
alias mvn20='JAVA_HOME=/usr/lib/jvm/jdk-20.0.2+9 mvn'
alias mvn21='JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 mvn'
#alias git='LANGUAGE=en_US:en git'
alias issues='cd /home/h168971/projetos/folhaweb/issues/$(date +"%Y/%m")'
alias gitless='git -c core.pager="less -x1,5"'

complete -F _complete_alias gitless

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

export PATH=".:/snap/bin:~/bin:$PATH:/usr/apps/Liquibase-4.3.5-bin"
# Add .NET Core SDK tools
export PATH="$PATH:/home/h168971/.dotnet/tools::~/.local/bin"

#export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
export JAVA_HOME="/usr/lib/jvm/jdk-11.0.24+8"
export HISTSIZE=36000
export HISTFILESIZE=36000

_complete_ssh_hosts ()
{
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        comp_ssh_hosts=`cat ~/.ssh/known_hosts | \
                       cut -f 1 -d ' ' | \
                       sed -e s/,.*//g | \
                       grep -v ^# | \
                       uniq | \
                       grep -v "\[" ;
                cat ~/.ssh/config | \
                        grep "^Host " | \
                       awk '{print $2}'
                `
        COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
        return 0
}
complete -F _complete_ssh_hosts ssh

get_git_branch() {
    #B=`git branch 2>/dev/null| awk '/\*/ { print $2; }'`
    B=`git branch 2>/dev/null |grep '*'|cut -f 1 -d ' ' --complement| sed -e 's/[\(\)]//g'`
    if [[ $B ]]
    then
        echo -e "($B) "
    else
        echo ""
    fi
}


alias galias='git alias'

_git_alias ()
{
        case "$cur" in
        --alias=*)
            __gitcomp "`~/bin/show_git_aliases.sh --all|awk '{print $1}'`" "" "${cur##--alias=}"
        return
            ;;
            -*)
                __gitcomp "
                           --all --alias= -h
                          "
        return
                ;;
        esac
}

complete -o bashdefault -o default -o nospace -F _git_alias galias

export NODE_OPTIONS="--max_old_space_size=2048"

. /etc/bash_completion.d/mvn
# . /etc/bash_completion.d/deno.bash
# . /etc/bash_completion.d/clang

complete -F _complete_alias mvn11
complete -F _complete_alias mvn17
complete -F _complete_alias mvn20
complete -F _complete_alias mvn21

alias dockerps="docker ps --format 'table {{ .ID }}\t{{.Image}}\t{{.Status}}\t{{ .Names }}'"

function set-title() {
  if [[ -z "$ORIG" ]]; then
    ORIG=$PS1
  fi
  TITLE="\[\e]2;$*\a\]"
  PS1=${ORIG}${TITLE}
}

PS_RED=$(tput setaf 1)
PS_GREEN=$(tput setaf 2)
PS_CYAN=$(tput setaf 6)
PS_WHITE=$(tput setaf 7)
PS_RESET="\[\033[0m\]"
PS_BOLD=$(tput bold)
# \[\e2; sets the title in terminal tab
export PS1="${PS_BOLD}${PS_RED}\$(get_git_branch)${PS_WHITE}[${PS_GREEN}\u@\h${PS_WHITE}:${PS_CYAN}\w${PS_WHITE}]\n$ ${PS_RESET}\[\e]2;\$(get_git_branch)\W\a\]"
#export PS1="\[\033[1m\033[31m\$(get_git_branch)\033[36m\][\u@\h:\w]\n>\[\033[0m\] \[\e]2;\$(get_git_branch)\W\a\]"


eval "$(register-python-argcomplete pipx)"


alias gcc='gcc -std=c11 -pedantic-errors -Wall -Wextra -Werror'
alias clang='clang -std=c11 -pedantic-errors -Wall -Wextra -Werror'

# bash parameter completion for the dotnet CLI

_dotnet_bash_complete()
{
  local word=${COMP_WORDS[COMP_CWORD]}

  local completions
  completions="$(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)"
  if [ $? -ne 0 ]; then
    completions=""
  fi

  COMPREPLY=( $(compgen -W "$completions" -- "$word") )
}

#complete -f -F _dotnet_bash_complete dotnet


alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.13.2-complete.jar:." org.antlr.v4.Tool'
alias grun='java -Xmx500M -cp "/usr/local/lib/antlr-4.13.2-complete.jar:." org.antlr.v4.gui.TestRig'

alias bugfix='ssh -t jbossdesenv ssh bugfix'
alias bugfixlog='ssh -t logaplicacoes ssh bugfix'
alias bugfixfdlv='ssh -t fdlv ssh bugfix'
alias vpn='snx'
# PATH="/home/hkotsubo/perl5/bin${PATH:+:${PATH}}"; export PATH;
# PERL5LIB="/home/hkotsubo/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
# PERL_LOCAL_LIB_ROOT="/home/hkotsubo/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
# PERL_MB_OPT="--install_base \"/home/hkotsubo/perl5\""; export PERL_MB_OPT;
# PERL_MM_OPT="INSTALL_BASE=/home/hkotsubo/perl5"; export PERL_MM_OPT;



# IMPORTANT: make sure dotnet is present in PATH before the next lines

# prepare csc alias

#DOTNETDIR=$(dirname $(dirname $(dotnet --info | grep "Base Path" | cut -d' ' -f 6)))
#CSCPATH=$(find $DOTNETDIR -name csc.dll -print | sort | tail -n1)
#NETSTANDARDPATH=$(find $DOTNETDIR -path *sdk/*/ref/netstandard.dll ! -path *NuGetFallback* -print | sort | tail -n1)
#alias csc='dotnet $CSCPATH /r:$NETSTANDARDPATH '

# prepare csc_run alias

if [ ! -w "$DOTNETDIR" ]; then
  mkdir -p $HOME/.dotnet
  DOTNETDIR=$HOME/.dotnet
fi

DOTNETCSCRUNTIMECONFIG=$DOTNETDIR/csc-console-apps.runtimeconfig.json

alias csc_run='dotnet exec --runtimeconfig $DOTNETCSCRUNTIMECONFIG '

if [ ! -f $DOTNETCSCRUNTIMECONFIG ]; then
  DOTNETRUNTIMEVERSION=$(dotnet --list-runtimes |
    grep Microsoft\.NETCore\.App | tail -1 | cut -d' ' -f2)

  cat << EOF > $DOTNETCSCRUNTIMECONFIG
{
  "runtimeOptions": {
    "framework": {
      "name": "Microsoft.NETCore.App",
      "version": "$DOTNETRUNTIMEVERSION"
    }
  }
}
EOF
fi


#. "$HOME/.asdf/asdf.sh"
#. "$HOME/.asdf/completions/asdf.bash"

# # bun
# export BUN_INSTALL="$HOME/.bun"
# export PATH=$BUN_INSTALL/bin:$PATH
# . "$HOME/.cargo/env"

# . "$HOME/.asdf/asdf.sh"
# . "$HOME/.asdf/completions/asdf.bash"
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.9.3-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
