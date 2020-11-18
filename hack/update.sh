#!/bin/bash


# This script can be used to automate the setting of git commits in the values file to the head of each branch specified in the
# package's git settings. To run simply run:

# ./hack/update.sh

# which will call updates on istio, clusterAuditor, gatekeeper, logging, monitoring and twistlock.  
# As more addons get added we will have to update the wrapper script to know about them, or loop
# over all addons.X section.

# To update just one package, pass it as an argument into the script:

# ./hack/update.sh monitoring



# Assumes we have yq installed
function update() {
   # Get the git repo
   REPO=`yq r chart/values.yaml "$1.git.repo"`
   # Get the current branch specified in the values file
   CURR_BRANCH=`yq r chart/values.yaml "$1.git.branch"`
   # use the ls-remote git command to pull put the newest commit on that branch
   NEW_HEAD=`git ls-remote ${REPO} | grep "refs/heads/${CURR_BRANCH}" | cut -f 1`

#    echo "REPO: ${REPO}"
#    echo "CURR_BRANCH: ${CURR_BRANCH}"
#    echo "NEW_HEAD: ${NEW_HEAD}"
   echo "Setting $1 (${REPO} ${CURR_BRANCH}) to newest commit: ${NEW_HEAD}"
   # Update the values file in place
   yq w -i chart/values.yaml "$1.git.commit" ${NEW_HEAD}
}

if [ "$1" == "" ]; then
    update istio
    update clusterAuditor
    update gatekeeper
    update logging
    update monitoring
    update twistlock
else
update $1
fi

