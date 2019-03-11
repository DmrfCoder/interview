#!/bin/sh
echo "git add."
git add .
echo "git commit -m $1:" 
git commit -m"$1"
echo "git push:"
git push
