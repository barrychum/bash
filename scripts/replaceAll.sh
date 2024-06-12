#!/bin/bash

function replaceAll() {
    # Define the list of file paths
    FILE_PATHS=(
        ./test.txt
        #    "./static/style.css"
        #    "./templates/index.html"
    )

    # Define the list of replacements
    REPLACEMENTS=(
        's/rp_id/rpx_id/g'
    )

    # Prompt user to confirm FILE_PATHS
    printf "\nThe following file paths will be processed:\n"
    for FILE_PATH in $FILE_PATHS; do
        echo $FILE_PATH
    done

    read "proceed_file_paths?Do you want to proceed with these file paths? (y/n): "
    if [[ $proceed_file_paths != "y" ]]; then
        echo "Operation cancelled by user."
        return 1
    fi

    # Prompt user to confirm REPLACEMENTS
    printf "\nThe following replacements will be made:\n"
    for REPLACEMENT in $REPLACEMENTS; do
        echo $REPLACEMENT
    done

    read "proceed_replacements?Do you want to proceed with these replacements? (y/n): "
    if [[ $proceed_replacements != "y" ]]; then
        echo "Operation cancelled by user."
        return 1
    fi
    printf "\n"

    # Loop through each file path
    for FILE_PATH in $FILE_PATHS; do
        printf "$FILE_PATH..."

        # Create a temporary copy of the file
        TEMP_FILE="${FILE_PATH}.tmp"
        cp $FILE_PATH $TEMP_FILE

        # Loop through each replacement command
        for REPLACEMENT in $REPLACEMENTS; do
            # Perform the replacement using sed
            sed -i '' "$REPLACEMENT" $TEMP_FILE
        done

        # Generate a diff file
        DIFF_FILE="${FILE_PATH}.diff"
        diff $FILE_PATH $TEMP_FILE >$DIFF_FILE

        # Overwrite the original file with the modified file
        mv $TEMP_FILE $FILE_PATH

        printf "\r$FILE_PATH done. Diff file created at $DIFF_FILE\n"
    done

    printf "\nAll replacements are done!\n"

    printf "To reverse the changes, use the following command:\n"
    printf "patch -R <original-file> < diff-file>\n"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    replaceAll "$@"
fi
