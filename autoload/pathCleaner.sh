remove_dup_path() {
    local OLD_PATH=$1
    local NEW_PATH
    NEW_PATH=$(echo "$OLD_PATH" | awk -v RS=: -v ORS=: '!seen[$0]++')
    echo "${NEW_PATH%:}" # Remove trailing colon
}


remove_invalid_path() {
    local input_path="$1"
    IFS=':' read -r -a path_array <<<"$input_path"
    local new_path=""
    for element in "${path_array[@]}"; do
        if [ -d "$element" ]; then
            if [ -z "$new_path" ]; then
                new_path="$element"
            else
                new_path="$new_path:$element"
            fi
        fi
    done
    echo "$new_path"
}

function clean_path() {
export PATH=$(remove_dup_path "$PATH")
export PATH=$(remove_invalid_path "$PATH")
}
