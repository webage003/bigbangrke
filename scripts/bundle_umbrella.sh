#!/usr/bin/env bash

# repo path argument
repo_path=$1
repo_name=$(basename $repo_path)
repo_url=$(git config --get remote.origin.url)
bundle_path=$repo_path/$repo_name.bundle

# vendor the umbrella repository
echo "Repo Path: $repo_path"
echo "Repo Name: $repo_name"
echo "Repository URL: $repo_url"
echo "Commit Ref Name: $CI_COMMIT_REF_NAME"

echo "Cleaning existing path $repo_path"
rm -rf $repo_path

echo "Cleaning existing bundle $bundle_path"
rm -rf $bundle_path

echo "Cloning $repo_url to $repo_path"
git clone $repo_url $repo_path

echo "Bundling repository at HEAD"
cd $repo_path
git bundle create ../$repo_name.bundle HEAD
cd -

test -f $bundle_path || { echo "Error: $bundle_path does not exist"; exit 1; }

echo "Deleting repository $repo_path"
rm -rf $repo_path