remove_dup_path() {
    local OLD_PATH=$1
    local NEW_PATH
    NEW_PATH=$(echo "$OLD_PATH" | awk -v RS=: -v ORS=: '!seen[$0]++')
    echo "${NEW_PATH%:}" # Remove trailing colon
}

remove_invalid_path() {
    local input_path="$1"
    local IFS=':'
    local new_path=""
    local unique_paths=""

    # Split the input_path into an array
    for element in $input_path; do
        if [ -d "$element" ] && [[ ":$unique_paths:" != *":$element:"* ]]; then
            if [ -z "$new_path" ]; then
                new_path="$element"
            else
                new_path="$new_path:$element"
            fi
            unique_paths="$unique_paths:$element"
        fi
    done

    echo "$new_path"
}

function clean_path() {
export PATH=$(remove_dup_path "$PATH")
export PATH=$(remove_invalid_path "$PATH")
}
