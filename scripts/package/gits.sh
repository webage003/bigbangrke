#!/bin/bash

# help text
function help {
    echo "Usage: $(basename $0) <repo_dir>"
    exit $1
}

# variables
REPO_DIR=$1
PACKAGE_DIR=$1/packages
UMBRELLA_DIR=$1/umbrella
UMBRELLA_REMOTE=$(git config --get remote.origin.url)

# make sure we're providing the repository dir
if [ -z "$REPO_DIR" ]; then
    echo "Error: Content for REPO_DIR variable not provided"
    help 1
fi

# debug statements
echo "> Repo Dir: $REPO_DIR"
echo "> Package Dir: $PACKAGE_DIR"
echo "> Umbrella Dir: $UMBRELLA_DIR"
echo "> Umbrella Remote: $UMBRELLA_REMOTE"

# remove old umbrella
echo "-- Removing existing umbrella"
ls -1d $UMBRELLA_DIR 2>/dev/null
rm -rf $UMBRELLA_DIR

# remove old packages
echo "-- Removing existing packages"
ls -1d $PACKAGE_DIR/* 2>/dev/null
rm -rf $PACKAGE_DIR/*

# Clone umbrella
echo "-- Cloning umbrella"
echo "$UMBRELLA_REMOTE"
git clone -q --no-checkout $UMBRELLA_REMOTE $UMBRELLA_DIR

# Clone core
echo "-- Cloning core packages"
yq r "chart/values.yaml" "*.git.repo" | while IFS= read -r repo; do
    echo "$repo"
    git -C $PACKAGE_DIR clone -q --no-checkout $repo >/dev/null
done

# Clone packages
echo "-- Cloning addon packages"
yq r "chart/values.yaml" "addons.*.git.repo" | while IFS= read -r repo; do
    echo "$repo"
    git -C $PACKAGE_DIR clone -q --no-checkout $repo >/dev/null
done

echo "-- Showing new umbrella"
ls -1d $UMBRELLA_DIR 2>/dev/null

echo "-- Showing new packages"
ls -1d $PACKAGE_DIR/* 2>/dev/null