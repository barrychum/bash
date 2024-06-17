
eval "$(/usr/local/bin/brew shellenv)"

# Source all .sh files in autoload directory
for file in ~/scripts/autoload/*.sh; do
  if [[ -f "$file" ]]; then
    source "$file"
  fi
done

alias pip=pip3
alias python=python3
