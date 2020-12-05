#!/usr/bin/env bash

# repo path argument
repo_path=$1

# vendor the umbrella repository
echo "Vendoring the umbrella repository"
UMBRELLA_URL=$(git config --get remote.origin.url)
UMBRELLA_HEAD=$(git rev-parse HEAD)
echo "Repo Path: $repo_path"
echo "Umbrella URL: $UMBRELLA_URL"
echo "Umbrella Head: $UMBRELLA_HEAD"
rm -rf $repo_path
git clone $UMBRELLA_URL $repo_path
cd $repo_path
git checkout $UMBRELLA_HEAD
git reset --hard
rm -rf .git
cd -