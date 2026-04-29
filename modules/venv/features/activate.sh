#!/bin/bash

venv_dir="$1"
shift

function help_activate() {
    printf "\033[35mfast venv activate\033[0m -n|--name <env_name> [-h|--help]\n" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -n, --name   Name of the virtual environment to activate (required)" >&2
    echo "  -h, --help   Show this help message (optional)" >&2
    echo "" >&2
    echo "Description:" >&2
    echo "  Activates the specified Python virtual environment located in '$venv_dir/<env_name>'." >&2
    echo "  The script will check if the specified virtual environment exists before attempting to activate it." >&2
    echo "  If the specified virtual environment does not exist, an error message will be displayed." >&2
    echo "" >&2
}

name=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        help|-h|--help)
            help_activate
            exit 0
            ;;
        -n|--name)
            name="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: '$1'. Use 'venv activate --help' for more information." >&2
            help_activate
            exit 127
            ;;
    esac
done

# Validate the environment name
if [ -z "$name" ]; then
    echo "Environment name is required. Use 'venv activate --help' for more information." >&2
    exit 1
fi

# Check if the virtual environment exists
if [ ! -d "$venv_dir/$name" ]; then
    echo "Virtual environment '$name' does not exist in '$venv_dir'." >&2
    exit 1
fi

# Check if another virtual environment is currently active
if [ -n "$VIRTUAL_ENV" ] && [ "$VIRTUAL_ENV" != "$venv_dir/$name" ]; then
    echo "Another virtual environment '$VIRTUAL_ENV' is currently active." >&2
    echo "Deactivating the currently active virtual environment before activating '$name'..." >&2
    deactivate
    exit 1
fi

# Check if the virtual environment is already active
if [ "$VIRTUAL_ENV" == "$venv_dir/$name" ]; then
    echo "Virtual environment '$name' is already active." >&2
    exit 0
fi

# Activate the virtual environment
source "$venv_dir/$name/bin/activate"
echo "Virtual environment '$name' activated successfully." >&2