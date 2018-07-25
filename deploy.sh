#!/bin/bash

current_branch=$(git rev-parse --abbrev-ref HEAD)

git branch -D deploy -f > /dev/null 2>&1
git checkout --orphan deploy
git reset
git add dist public -f
git commit -m "Initial commit"
git push origin deploy -f
git add .
git checkout ${current_branch}