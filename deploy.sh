#!/bin/bash

if [ -n `git branch | grep "* master"` ]
then
    git checkout gh-pages && git merge --ff-only master && git push origin gh-pages && git checkout master
else
    echo "Switch to master"
    exit 1
fi

