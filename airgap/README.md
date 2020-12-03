# umbrella.airgap

Umbrella airgap resources and documentation.

# Image List

Use this folder as your top-level working directory.

## Steps

1. Deploy initial blank cluster.

2. Obtain "false" image list:

    ```
    ./list-images.sh > lists/images-false.txt
    ```

3. Install bigbang with all optional components.

4. Obtain initial "true" images list:

    ```
    ./list-images.sh > lists/images-initial.txt
    ```

5. Obtain "true" image list without "false" images:

    ```
    grep -v -x -f lists/images-false.txt lists/images-initial.txt > lists/images.txt
    ```

6. Obtain image tarball:

    ```
    ./bundle-images.sh --images tarballs/images.tar.gz
    ```