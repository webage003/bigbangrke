# umbrella.airgap

Umbrella airgap resources and documentation.

# Image List

Use this folder as your top-level working directory.

## Steps

1. Deploy initial blank cluster.

2. Obtain "false" image list:

    ```
    ./list-images.sh > images-false.txt
    ```

3. Install bigbang with all optional components.

4. Obtain initial "true" images list:

    ```
    ./list-images.sh > images-initial.txt
    ```

5. Obtain "true" image list without "false" images:

    ```
    grep -v -x -f images-false.txt images-initial.txt > images.txt
    ```