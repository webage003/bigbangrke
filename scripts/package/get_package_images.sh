# Pipeline has the var, just added for testing
VALUES_FILE='chart/values.yaml'
IMAGE_FILE="images.txt"
RESULTS="package-images.yaml"
header_done=0

# Start output header
echo "---"
echo "package-image-list:"

# Generate a list of all images in all Big Bang Packages
yq e '(.,.addons) | ... comments="" | .[] | (path | join(".")) ' "${VALUES_FILE}" | while IFS= read -r package; do
    gitrepo=$(yq e ".${package}.git.repo" "${VALUES_FILE}")
    version=$(yq e ".${package}.git.tag" "${VALUES_FILE}")
    # echo $package $version
    # Since keys aren't always packages
    if [[ -z "$version" || "$version" == "null" ]]; then
        continue
    fi
    # Remove prefix
    gitrepo=${gitrepo#"https://repo1.dso.mil/"}
    # Remove suffix
    gitrepo=${gitrepo%".git"}
    # Replace `/` with `%2F`
    gitrepo=${gitrepo//\//%2F}
    # Curl gitlab API to get project ID
    projid=$(curl -s https://repo1.dso.mil/api/v4/projects/${gitrepo} | jq '.id')
    #echo $projid
    # Curl gitlab API + S3 file to get images list
    images=$(curl -s $(curl -s https://repo1.dso.mil/api/v4/projects/${projid}/releases/${version} | jq -r '.assets.links[] | select(.name=="images.txt").url'))
    package=${package#"addons."}

    # Generate the output in JSON format
    #echo "Images for $package:"
    header_done=0
    for image in $images
    do
      if [ -n "$(grep ${image} $IMAGE_FILE)" ]
      then
        if [ ${header_done} == 0 ] ; then
          echo "  ${package}: "
          echo "    version: \"${version}\""
          echo "    images:"
          header_done=1
        fi
        echo "      - \"${image}\""
      fi
    done
done


