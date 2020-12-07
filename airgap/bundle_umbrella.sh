#!/usr/bin/env bash

set -x

# repo path argument
repo_path=$1
repo_name=$(basename $repo_path)

# vendor the umbrella repository
echo "Bundling the $repo_name repository"
echo "Repo Path: $repo_path"
echo "Repo Name: $repo_name"
echo "Repository URL: $CI_REPOSITORY_URL"
echo "Commit Ref Name: $CI_COMMIT_REF_NAME"

echo "Cleaning existing path $repo_path"
rm -rf $repo_path
echo "Cloning $CI_REPOSITORY_URL to $repo_path"
git clone $UMBRELLA_URL $repo_path
cd $repo_path
echo "Bundling repository for $CI_COMMIT_REF_NAME"
git bundle create ../$repo_name.bundle $CI_COMMIT_REF_NAME
cd -
echo "Deleting repository $repo_path"
rm -rf $repo_path