#!/bin/bash
# show commits that contains the hash

if [ $# -lt 1 ]
then
	N=`basename ${0}`
	echo "Usage: ${N} hash [options for git log]"
	echo "  Show commits that contains the hash"
	exit 0;
fi

obj_name="$1"
shift
git log "$@" --pretty=format:'%T %H %s' \
| while read tree commit subject ; do
  if git ls-tree -r $tree | grep -q "$obj_name" ; then
	echo $commit "$subject"
  fi
done
