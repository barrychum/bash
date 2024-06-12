#!/bin/bash

# Main function to create zip file
create_zip() {
    # Function to prompt for a new zip file name if the target already exists
    get_new_zip_name() {
        while true; do
            read "NEW_ZIP_FILE?The zip file '$1' already exists. Enter a new name for the zip file (without extension): "
            if [ -z "$NEW_ZIP_FILE" ]; then
                echo "You must enter a valid name."
            else
                if [[ "$NEW_ZIP_FILE" != *.zip ]]; then
                    NEW_ZIP_FILE="$NEW_ZIP_FILE.zip"
                fi
                if [ ! -f "$NEW_ZIP_FILE" ]; then
                    echo "$NEW_ZIP_FILE"
                    return
                else
                    echo "The file '$NEW_ZIP_FILE' already exists. Please enter a different name."
                fi
            fi
        done
    }

    # Function to display help message
    show_help() {
        echo "Usage: ./create_zip.sh [--help]"
        echo ""
        echo "This script creates a zip file named 'archive.zip' (or another specified name if 'archive.zip' already exists)"
        echo "and excludes files and directories listed in the '.zipignore' file."
        echo ""
        echo "The .zipignore file should contain one file or directory per line that you want to exclude."
        echo "Wildcards are supported. Example:"
        echo ""
        echo "  venv/"
        echo "  __pycache__/"
        echo "  *.log"
        echo "  temp_*"
        echo "  another_folder_to_exclude/"
        echo ""
        echo "If the script is run with the --help argument, this help message is displayed."
    }

    # Check for --help argument
    if [[ "$1" == "--help" ]]; then
        show_help
        return
    fi

    # Name of the zip file
    ZIP_FILE="archive.zip"

    # Check if the zip file already exists and prompt for a new name if it does
    if [ -f "$ZIP_FILE" ]; then
        ZIP_FILE=$(get_new_zip_name "$ZIP_FILE")
    fi

    # Initialize array for exclusion patterns
    EXCLUDE_PATTERNS=()

    # Check if .zipignore file exists and read the exclusions
    if [ -f ".zipignore" ]; then
        while IFS= read -r line || [ -n "$line" ]; do
            # Only add non-empty lines to the exclude list
            if [ -n "$line" ]; then
                # Append wildcard to exclude all contents of directories
                if [[ "$line" == */ ]]; then
                    EXCLUDE_PATTERNS+=("$line*")
                else
                    EXCLUDE_PATTERNS+=("$line")
                fi
            fi
        done < .zipignore
    fi

    # Remove existing zip file if it exists
    if [ -f "$ZIP_FILE" ]; then
        echo "Removing existing $ZIP_FILE"
        rm "$ZIP_FILE"
    fi

    # Create the zip file with exclusions
    echo "Creating zip file $ZIP_FILE with exclusions from .zipignore"
    # Convert exclude patterns to zip exclude options
    EXCLUDE_OPTIONS=()
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        EXCLUDE_OPTIONS+=("-x" "$pattern")
    done

    zip -r "$ZIP_FILE" . "${EXCLUDE_OPTIONS[@]}"

    # Confirm completion
    echo "Created $ZIP_FILE successfully."
}

# When sourcing the script, create_zip won't run automatically.
# Only run create_zip if the script is executed directly.
# Check shebang.  zsh won't work.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pipinstall "$@"
fi