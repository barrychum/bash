#!/bin/bash

# Array of directories containing your cheatsheets
CHEATSHEET_DIRS=(
  "$HOME/Documents/cheatsheet"
  "$HOME/Documents/GitHub/barrychum/cheatsheet.wiki"
  # Add more directories as needed
)

# Array of regex patterns to exclude
EXCLUDE_PATTERNS=(
  ".*-draft\.md"
  ".*-old\.md"
  "_.*\.md"
  # Add more patterns as needed
)

# Function to check if a file matches any exclude pattern using regex
exclude_file() {
  local file="$1"
  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    if [[ "$(basename "$file")" =~ $pattern ]]; then
      return 0
    fi
  done
  return 1
}

# Check if directories exist and gather all .md files excluding patterns
files=()
for dir in "${CHEATSHEET_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    while IFS= read -r -d '' file; do
      exclude_file "$file" || files+=("$file")
    done < <(find "$dir" -type f -name "*.md" -print0)
  else
    echo "Directory not found: $dir"
  fi
done

# Check if there are any .md files found
if [ ${#files[@]} -eq 0 ]; then
  echo "No cheatsheet files found in the specified directories."
  exit 1
fi

# Use fzf to select a cheatsheet
selected=$(printf '%s\n' "${files[@]}" | fzf --height 40% --reverse --border)

# Check if a file was selected
if [ -z "$selected" ]; then
  echo "No cheatsheet selected."
  exit 1
fi

# Open the selected cheatsheet in the default Markdown viewer or editor
open "$selected"
