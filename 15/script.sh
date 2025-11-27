#!/bin/bash

# ensure main is latest 
git checkout main 
git pull 

# create new branch
git checkout -b feature/orange

# add file 
echo "This file contains oranges" > oranges

# commit changes
git add oranges
git commit -m "added oranges."

# push
git push --set-upstream origin feature/orange

# merge to main
git checkout main
git merge feature/orange

# push 
git push 
