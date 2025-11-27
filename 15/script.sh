#!/bin/bash

git checkout -b feature/orange
touch oranges
echo "This file contains oranges" >> oranges
git add oranges
git commit -m "added oranges."
git push --set-upstream origin feature/orange

git checkout main
git merge feature/orange
