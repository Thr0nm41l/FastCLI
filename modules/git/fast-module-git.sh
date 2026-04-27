#!/bin/bash

__VERSION="1.0.0"
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
    echo "FastCLI Git Module - Version $__VERSION"
}

function full_help() {
    local script
    for file in "${script_list[@]}"; do
        if [ -f "$__SCRIPT_PATH/$file" ]; then
            bash "$__SCRIPT_PATH/$file" help
        fi
    done
}



if [ "$subcommand" != "" ]; then
    shift
    echo "Executing subcommand: $subcommand with arguments: $@"
    case "$subcommand" in
        version)
            version
            ;;
        help)
            echo "FastCLI Git Module - All subcommands help:"
            echo ""
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