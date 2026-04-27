#!/bin/bash

# This file is sourced by your shell configuration to set up FastCLI environment variables and functions.
# FastCLI - A fast and efficient command-line interface for developers

__VERSION="1.1.0"
__DIR_NAME=$(dirname "$(readlink -f "${BASH_SOURCE[0]:-$0}")")

function fast() {

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

    function update() {
        echo "Updating FastCLI and all modules..." >&2
        git -C "$fast_path" pull origin main
        for module in "${module_list[@]}"; do
            git -C "$fast_path/modules/$module" pull origin main
        done
        echo "Update complete." >&2
    }

    function fast_help() {
        echo "FastCLI - A fast and efficient command-line interface for developers" >&2
        echo "" >&2
        echo "Usage: fast <command> [subcommand] [options]" >&2
        echo "" >&2
        printf "\033[32mAvailable commands:\033[0m\n" >&2
        printf "\033[35mfast help\033[0m <module>\n" >&2
        echo "Options:" >&2
        echo "  <module>  Show help for a specific module" >&2
        echo "" >&2
        echo "Description:" >&2
        echo "  Show this help message and exit" >&2
        echo "" >&2
        printf "\033[35mfast version\033[0m\n" >&2
        echo "Options:" >&2
        echo "  No options available" >&2
        echo "" >&2
        echo "Description:" >&2
        echo "  Show FastCLI and loaded modules versions" >&2
        echo "" >&2
        printf "\033[35mfast update\033[0m\n" >&2
        echo "Options:" >&2
        echo "  No options available" >&2
        echo "" >&2
        echo "Description:" >&2
        echo "  Update FastCLI and all modules to the latest version from the repository" >&2
        echo "" >&2

        for module in "${module_list[@]}"; do
            bash "$fast_path/modules/$module/fast-module-$module.sh" help
        done
    }

    function fast_version() {
        printf "\n" >&2
        cat "$__DIR_NAME/banner.txt"
        printf "\n\n" >&2
        echo "FastCLI version: $__VERSION" >&2
        echo " Loaded modules:" >&2

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
            *)
                if [[ " ${module_list[*]} " == *" $command "* ]]; then
                    bash "$fast_path/modules/$command/fast-module-$command.sh" "$@"
                    return $?
                else
                    echo "Unknown command: $command" >&2
                    fast_help
                    return 127
                fi
                ;;
        esac
    else
        echo "No command provided." >&2
        fast_help
        return 1
    fi
}