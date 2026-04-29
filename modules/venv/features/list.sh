#!/bin/bash

venv_dir="$1"
shift

function help_list() {
    printf "\033[35mfast venv list\033[0m -n|--name <env_name> [-h|--help]\n" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -n, --name   Name of the virtual environment to list (optional)" >&2
    echo "  -h, --help   Show this help message (optional)" >&2
    echo "" >&2
    echo "Description:" >&2
    echo "  Lists all available Python virtual environments in '$venv_dir' and lists their modules." >&2
    echo "  If a specific environment name is provided, it will only list the modules installed in that virtual environment." >&2
    echo "" >&2
}

name=""
already_activated_venv=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        help|-h|--help)
            help_list
            exit 0
            ;;
        -n|--name)
            name="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: '$1'. Use 'venv list --help' for more information." >&2
            help_list
            exit 127
            ;;
    esac
done

# Check if the virtual environment is currently active and store its name if it is
if [ -n "$VIRTUAL_ENV" ]; then
    already_activated_venv=$(basename "$VIRTUAL_ENV")
    deactivate
fi

# List all virtual environments in the directory and list the modules installed in each virtual environment, or if a specific environment name is provided, list the modules installed in that virtual environment
if [ -z "$name" ]; then
    if [ -d "$venv_dir" ]; then
        echo "Available virtual environments in '$venv_dir':" >&2
        echo "" >&2
        for dir in "$venv_dir"/*; do
            if [ -d "$dir" ]; then
                echo "=> $(basename "$dir")" >&2
                echo "" >&2
                source "$dir/bin/activate"
                pip list --format=columns | sed 's/^/    /'
                deactivate
                echo "" >&2
            fi
        done
    else
        echo "Directory '$venv_dir' does not exist." >&2
        exit 1
    fi
else
    # List the modules installed in the specified virtual environment
    if [ -d "$venv_dir/$name" ]; then
        echo "Modules installed in virtual environment '$name':" >&2
        source "$venv_dir/$name/bin/activate"
        pip list --format=columns
        deactivate
    else
        echo "Virtual environment '$name' does not exist in '$venv_dir'." >&2
        exit 1
    fi
fi

# If there was a virtual environment that was already activated before running the list command, reactivate it
if [ -n "$already_activated_venv" ]; then
    source "$venv_dir/$already_activated_venv/bin/activate"
    echo "Reactivated previously active virtual environment '$already_activated_venv'." >&2
fi