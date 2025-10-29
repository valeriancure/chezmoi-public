#!/bin/bash

set -e

# Parse arguments
MODE="normal"
DISTRO="ubuntu24"

if [[ "$1" == "--debug" ]]; then
    MODE="debug"
    DISTRO="${2:-ubuntu24}"
elif [[ -n "$1" ]]; then
    # First arg is distro name
    DISTRO="$1"
fi

case $DISTRO in
    ubuntu24)
        CONTAINERFILE="Containerfile.ubuntu24"
        IMAGE_NAME="chezmoi-test-ubuntu24"
        CONTAINER_NAME="chezmoi-test-ubuntu24-debug"
        ;;
    almalinux10|alma10)
        CONTAINERFILE="Containerfile.almalinux10"
        IMAGE_NAME="chezmoi-test-almalinux10"
        CONTAINER_NAME="chezmoi-test-almalinux10-debug"
        ;;
    *)
        echo "Usage: $0 [--debug] [ubuntu24|almalinux10]"
        echo ""
        echo "Examples:"
        echo "  $0                    # normal mode, ubuntu24"
        echo "  $0 ubuntu24           # normal mode, ubuntu24"
        echo "  $0 almalinux10        # normal mode, almalinux10"
        echo "  $0 --debug            # debug mode, ubuntu24"
        echo "  $0 --debug ubuntu24   # debug mode, ubuntu24"
        echo ""
        echo "Modes:"
        echo "  normal (default) - ephemeral container, auto-cleanup"
        echo "  --debug          - persistent container for debugging"
        exit 1
        ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Building container for $DISTRO ==="
cd "$REPO_DIR"
podman build -t $IMAGE_NAME -f test-containers/$CONTAINERFILE .

echo ""
echo "=== Running container in $MODE mode ==="
echo ""

if [[ "$MODE" == "debug" ]]; then
    # Debug mode: persistent container, survives errors
    echo "🐛 Debug mode: container will persist for debugging"
    echo "   - Container name: $CONTAINER_NAME"
    echo "   - To re-enter: podman start -ai $CONTAINER_NAME"
    echo "   - To remove: podman rm $CONTAINER_NAME"
    echo ""
    
    # Remove old container if exists
    podman rm -f $CONTAINER_NAME 2>/dev/null || true
    
    podman run -it --name $CONTAINER_NAME $IMAGE_NAME bash -c "
        set +e  # Don't exit on errors
        echo '=== Applying chezmoi dotfiles ===' &&
        chezmoi apply
        exit_code=\$?
        echo '' &&
        if [ \$exit_code -eq 0 ]; then
            echo '✅ Installation complete!' 
        else
            echo '❌ Installation failed (exit code: '\$exit_code')' 
            echo '   Container kept alive for debugging'
        fi &&
        echo 'Test commands: nvim --version, tmux -V, zsh --version, lazygit --version' &&
        echo '' &&
        exec bash
    "
else
    # Normal mode: ephemeral container, auto-cleanup
    echo "✨ Normal mode: container will be removed after exit"
    echo ""
    
    podman run -it --rm $IMAGE_NAME bash -c "
        echo '=== Applying chezmoi dotfiles ===' &&
        chezmoi apply &&
        echo '' &&
        echo '=== Installation complete! Dropping into shell ===' &&
        echo 'Test commands: nvim --version, tmux -V, zsh --version, lazygit --version' &&
        echo '' &&
        exec bash
    "
fi
