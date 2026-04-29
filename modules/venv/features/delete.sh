#!/bin/bash

venv_dir="$1"
shift

function help_delete() {
    printf "\033[35mfast venv delete\033[0m -n|--name <env_name> [-h|--help]\n" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -n, --name   Name of the virtual environment to delete (required)" >&2
    echo "  -h, --help   Show this help message (optional)" >&2
    echo "" >&2
    echo "Description:" >&2
    echo "  Deletes the specified Python virtual environment located in '$venv_dir/<env_name>'." >&2
    echo "  The script will check if the specified virtual environment exists before attempting to delete it." >&2
    echo "  If the specified virtual environment does not exist, an error message will be displayed." >&2
    echo "" >&2
}

name=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        help|-h|--help)
            help_delete
            exit 0
            ;;
        -n|--name)
            name="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: '$1'. Use 'venv delete --help' for more information." >&2
            help_delete
            exit 127
            ;;
    esac
done

# Validate the environment name
if [ -z "$name" ]; then
    echo "Environment name is required. Use 'venv delete --help' for more information." >&2
    exit 1
fi

# Check if the virtual environment exists
if [ ! -d "$venv_dir/$name" ]; then
    echo "Virtual environment '$name' does not exist in '$venv_dir'." >&2
    exit 1
fi

# Check if the virtual environment is currently active
if [ "$VIRTUAL_ENV" == "$venv_dir/$name" ]; then
    echo "Deactivating virtual environment '$name'..." >&2
    deactivate
fi

# Delete the virtual environment
rm -rf "$venv_dir/$name"
echo "Virtual environment '$name' deleted successfully." >&2