#!/bin/bash

if [ ${1-ops} = '-h' ]
  then
    echo -e "Uso: git alias [opcoes]\n"
    echo -e "Mostra os alias configurados no git:\n"
    echo -e "\t--all\t\t\tMostra todos"
    echo -e "\t--alias=<aliasname>\tMostra apenas o alias <aliasname>"
    echo -e "\nPor default, mostra todos (exceto o proprio 'git alias')"
    exit 0
fi

if [ $# -le 1 ]
  then
    if [[ "${1-noparam}" =~ "--alias=" ]]
        then
	    IFS="="
	    read -ra PARAM <<< "$1"
	    git config --get-regexp ^alias\.${PARAM[1]}$ | sed -e s/^alias\.// -e s/\ /\ =\ /
        else
    	    if [ ${1-noparameter} = '--all' ]
	        then
	  	    P=`date`
		else
	  	    P='alias'
    	    fi

	    git config --get-regexp ^alias\. | sed -e s/^alias\.// -e s/\ /\\\t=\ / | grep -v "${P}"| sort
    fi
fi

