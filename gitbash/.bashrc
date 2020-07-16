alias la='ls -A'
alias ps='ps -efW'
alias subl="/c/Program\ Files/Sublime\ Text\ 3/subl.exe"
PATH=/c/Arquivos\ de\ Programas/Java/jdk1.8.0_202/bin:/c/java/apache-maven-3.6.1/bin:/c/Arquivos\ de\ Programas/nodejs/:$PATH
JAVA_HOME=/c/Arquivos\ de\ Programas/Java/jdk1.8.0_202

unset TMOUT

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
		if [ ${#B} -gt 45 ]
		then
			echo -e "(${B:0:42}...) "
		else
			echo -e "($B) "
		fi
	else
		echo ""
	fi
}

#export PS1="\[\033[1m\033[31m\$(get_git_branch)\033[36m\][\u@git-bash:\w]\[\033[0m\] "
export PS1="\[\033[1m\033[31m\$(get_git_branch)\033[36m\][\u@\033[33mgit-bash\033[36m:\w]\[\033[0m\] "

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

#. ~/.maven_completion.sh
#export HTTP_PROXY=http://url:port
#export HTTP_PROXY_USER=user
#export HTTP_PROXY_PASS=pass
#export HTTPS_PROXY=http://url:port
#export HTTPS_PROXY_USER=user
#export HTTPS_PROXY_PASS=pass
export NODE_OPTIONS="--max_old_space_size=2048"

command_not_found_handle () {
	#DIRS=`echo $PATH | sed -e 's/:/ /g'`
	CMDS=`find /mingw64/bin/ ~/bin /bin /usr/bin -type f -perm -u+x 2>/dev/null |awk -F"/" '{print $NF}'|cut -d '.' -f 1|sort|uniq`
	for c in git java ruby $CMDS 
	do
		if [[ $1 == ${c}* ]]; then
			${c} "${1#${c}}" "${@:2}"
			return $?  
		fi
	done
        printf 'bash: %s: command not found\n' "$1" >&2
        return 127
}

alias mvnproperties='MAVEN_OPTS=" -XshowSettings:properties" mvn --version'
alias maventest='mvn clean test -DskipTests=false -DfailIfNoTests=false'
