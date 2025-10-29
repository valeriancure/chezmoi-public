#!/bin/bash

set -e

DISTRO=${1:-ubuntu24}

case $DISTRO in
    ubuntu24)
        CONTAINERFILE="Containerfile.ubuntu24"
        IMAGE_NAME="chezmoi-test-ubuntu24"
        ;;
    almalinux10|alma10)
        CONTAINERFILE="Containerfile.almalinux10"
        IMAGE_NAME="chezmoi-test-almalinux10"
        ;;
    *)
        echo "Usage: $0 [ubuntu24|almalinux10]"
        exit 1
        ;;
esac

echo "=== Building container for $DISTRO ==="
podman build -t $IMAGE_NAME -f test-containers/$CONTAINERFILE .

echo ""
echo "=== Running container ==="
echo "Inside the container, run:"
echo "  chezmoi init --apply /home/testuser/chezmoi-public"
echo ""

podman run -it --rm \
    -v "$(pwd):/home/testuser/chezmoi-public:ro" \
    $IMAGE_NAME
