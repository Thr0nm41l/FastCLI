#!/bin/bash

# This file is sourced by your shell configuration to set up FastCLI environment variables and functions.
# FastCLI - A fast and efficient command-line interface for developers

__DIR_NAME=$(dirname "$(readlink -f "${BASH_SOURCE[0]:-$0}")")
__VERSION="1.0.0"

fast() {

    function get_modules_names() {
        local modules=()
        for folder in "$fast_path"/modules/*; do
            if [ -d "$folder" ]; then
                modules+=("$(basename "$folder")")
            fi
        done
        echo "${modules[@]}"
    }

    local fast_path="$__DIR_NAME"
    local command="$1"
    local module_list=($(get_modules_names))

    function fast_help() {
        echo "FastCLI - A fast and efficient command-line interface for developers"
        echo ""
        echo "Usage: fast <command> [subcommand] [options]"
        echo ""
        echo "Available commands:"
        echo "  help    Show this help message"
        echo "  version Show FastCLI and all installed modules versions"
        # Add more commands here as needed
    }

    function fast_version() {
        echo "FastCLI version: $__VERSION"
        echo "Modules:"

        for module in "${module_list[@]}"; do
            bash "$fast_path/modules/$module/fast-module-$module.sh" version
        done
    }


    if [ -n "$command" ]; then
        shift

        case "$command" in
            help)
                fast_help
                return 0
                ;;
            version)
                fast_version
                return 0
                ;;
        esac

        if [[ " ${module_list[*]} " == *" $command "* ]]; then
            bash "$fast_path/modules/$command/fast-module-$command.sh" "$@"
            return $?
        fi

    else
        fast_help
        return 127
    fi


    
}