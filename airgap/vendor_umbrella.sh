#!/usr/bin/env bash

# repo path argument
repo_path=$1

# vendor the umbrella repository
echo "Vendoring the umbrella repository"
echo "Repo Path: $repo_path"
echo "Repository URL: $CI_REPOSITORY_URL"
echo "Commit Ref Name: $CI_COMMIT_REF_NAME"
rm -rf $repo_path
git clone $UMBRELLA_URL $repo_path
cd $repo_path
git checkout $UMBRELLA_HEAD
git reset --hard
rm -rf .git
cd -