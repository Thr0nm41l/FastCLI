#!/bin/bash

__MODULE_NAME="Git"
__VERSION="1.0.1"
__DIR_NAME=$(dirname "$(readlink -f "${BASH_SOURCE[0]:-$0}")")
__SCRIPT_PATH="$__DIR_NAME/features"

function get_script_names() {
    local scripts=()
    for file in "$__SCRIPT_PATH"/*.sh; do
        if [ -f "$file" ]; then
            scripts+=("$(basename "$file")")
        fi
    done
    echo "${scripts[@]}"
}

script_list=($(get_script_names))
subcommand="$1"

function version() {
    echo "FastCLI $__MODULE_NAME Module - Version $__VERSION" >&2
}

function full_help() {
    printf "\033[35mfast git help\033[0m\n" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  No options available" >&2
    echo "" >&2
    echo "Description:" >&2
    echo "  Show all available subcommands and their descriptions for the $__MODULE_NAME module" >&2
    echo "" >&2
    local script
    for file in "${script_list[@]}"; do
        if [ -f "$__SCRIPT_PATH/$file" ]; then
            bash "$__SCRIPT_PATH/$file" help
        fi
    done
}

if [ "$subcommand" != "" ]; then
    shift
    case "$subcommand" in
        version)
            version
            ;;
        help)
            printf "\033[33mFastCLI $__MODULE_NAME Module - All subcommands help:\033[0m\n" >&2
            echo "" >&2
            full_help
            ;;
        *)
            if [[ " ${script_list[*]} " == *" $subcommand.sh "* ]]; then
                bash "$__SCRIPT_PATH/$subcommand.sh" "$@"
                exit $?
            else
                echo "Unknown subcommand: $subcommand" >&2
                full_help
                exit 127
            fi
            ;;
    esac
else
    echo "No subcommand provided." >&2
    full_help
    exit 1
fi