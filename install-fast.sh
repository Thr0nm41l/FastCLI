#!/bin/bash

pwd="$(dirname "$(readlink -f "$0")")"

# Get default Shell
default_shell=$(basename "$SHELL")

# Get default shell config file
if [ "$default_shell" == "bash" ]; then
    shell_config="$HOME/.bashrc"
elif [ "$default_shell" == "zsh" ]; then
    shell_config="$HOME/.zshrc"
else
    echo "Unsupported shell: $default_shell"
    exit 1
fi

# Check if config file exists, if not create it
if [ -f "$shell_config" ]; then
    echo "Shell config file found: $shell_config"
else
    echo "Shell config file not found. Creating: $shell_config"
    touch "$shell_config"
fi 

# Check if FastCLI is in current directory
if [ -f "$pwd/fast.sh" ]; then
    # Add source line to shell config if not already present
    if ! grep -q "source $pwd/fast.sh" "$shell_config"; then
        echo "Adding FastCLI source line to $shell_config"
        echo -e "\n# FastCLI\nif [ -f \"$pwd/fast.sh\" ]; then\nsource \"$pwd/fast.sh\"\nfi" >> "$shell_config"
        echo "FastCLI has been added to your shell configuration."
    else
        echo "FastCLI source line already present in $shell_config."
    fi

    # If FAST_EMAIL is not set, prompt user to enter email and save it in shell config
    if [ -z "$FAST_EMAIL" ]; then
        echo Enter your email for FastCLI: 
        read email
        echo -e "\n# FastCLI email\n    export FAST_EMAIL=\"$email\"" >> "$shell_config"
        echo "Email has been saved to your shell configuration."
    else
        echo "FAST_EMAIL is already set to $FAST_EMAIL."
    fi

    echo ""
    echo "FastCLI installation complete. Please restart your terminal or run 'source $shell_config' to start using FastCLI."

else
    echo "FastCLI not found in current directory. Please run this script from the FastCLI directory."
    exit 1
fi