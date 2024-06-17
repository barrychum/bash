#!/bin/bash

pipinstall() {
    # Function to activate the venv
    activate_venv() {
        source venv/bin/activate # Adjust path if your venv bin path is different
    }

    check_and_activate_venv() {
        # Check if venv is already activated
        if [[ -n "$VIRTUAL_ENV" ]]; then
            echo "Virtual environment is already activated: $VIRTUAL_ENV"
        else
            # Check if venv directory exists
            if [ -d venv ]; then
                echo "Virtual environment directory found. Activating..."
                activate_venv
            else
                echo "Virtual environment directory not found. Creating new venv..."
                python3 -m venv venv # Adjust python version if needed
                activate_venv
            fi
            echo "Virtual environment is now active: $VIRTUAL_ENV"
        fi
    }

    check_and_activate_venv

    # If no arguments provided, list installed packages
    if [[ -z "$@" ]]; then
        pip list
        return 0 # Exit with zero code to indicate successful listing
    fi

    # Install all provided packages using pip
    # for package in "$@"; do
    #    pip install "$package"
    # done
    pip install "$@"
    
    # echo "Successfully installed packages: $@"
    echo "Successfully installed packages: \e[1m$@\e[0m"
}

# When sourcing the script, pipinstall won't run automatically.
# Only run pipinstall if the script is executed directly.
# check shebang. zsh won't work
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pipinstall "$@"
fi
