#!/bin/bash

INTERACTIVE=1

REPO_DIR="/gitlab/repositories"

GOGS_URL=""
GOGS_TOKEN=""

GOGS_UID="1"
GOGS_MIRROR="false"
GOGS_PRIVATE="false"

# Ignore gitlab wiki repositories
IGNORE_WIKI=1

#Hack to add directory the repository is in to name
LONG_NAME=1

# Remove trailing .git from directory
REMOVE_TRAILING_GIT=1

import() {
    if [[ $IGNORE_WIKI == 1 && $1 == *".wiki.git" ]]; then
	return
    fi
    description=$(<description)

   if [[ $LONG_NAME == 1 ]]; then
        name=$(basename $(dirname `pwd`))
	name+="_$1"
    else
	name=$1
    fi

    if [[ $REMOVE_TRAILING_GIT == 1 ]]; then
	name="${name%????}"
    fi
 
    if [[ $INTERACTIVE == 1 ]]; then
	read -n 1 -r -p "Import from "`pwd`" with name: $name (y/n): "
        echo ''	
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	   echo $'Skipping repository\n'
           return
        fi
    fi
    
    curl -k -H "Content-Type: application/json" \
    -H "Authorization: token $GOGS_TOKEN" \
    -X POST -d '{ 
	"clone_addr": "'`pwd`'", 
	"uid": '"$GOGS_UID"',
	"repo_name": "'"$name"'",
	"mirror": '"$GOGS_MIRROR"',
	"private": '"$GOGS_PRIVATE"',
	"description": "'"$description"'" }' "$GOGS_URL/api/v1/repos/migrate"

   echo $'\n'
    
}

searchdir() {
    for d in "$@"; do
        test -d "$d" -a \! -L "$d" || continue
        cd "$d"
        if [ -f "HEAD" ]; then
	    import $d
        else
            searchdir *
        fi
        cd ..
    done
}


if [[ -d "$REPO_DIR" ]]; then
    cd "$REPO_DIR"
else
    exit "Repo directory not found"
fi
	
searchdir *

