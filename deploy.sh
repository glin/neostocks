#!/bin/bash

if ! git diff-index --quiet HEAD --; then
    echo "local changes found. aborting."
    exit 1
fi

if [ ! -d "dist" ]; then
    echo "'dist' directory not found. building."
    npm run build
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)

git branch -D deploy -f > /dev/null 2>&1
git checkout --orphan deploy
git reset
git add dist -f
git commit -m "Initial commit"
git push origin deploy -f
git add .
git checkout ${current_branch}