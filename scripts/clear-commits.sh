#!/bin/bash

# Ask for the repository path
read -p "Enter the GitHub repository URL (HTTPS): " REPO_URL

# Generate the SSH repository URL
SSH_REPO_URL=$(echo $REPO_URL | sed -e 's/https:\/\/github.com\//git@github.com:/')

# Generate a new branch name with a timestamp
NEW_BRANCH="new-branch-$(date +%Y%m%d%H%M%S)"

# Authenticate with GitHub
gh auth login

# Clone the repository
git clone $REPO_URL repo
cd repo || { echo "Failed to change directory to repo"; exit 1; }

# Create a new orphan branch
git checkout --orphan $NEW_BRANCH

# Add all files to the new branch
git add .

# Commit the changes
git commit -m "Initial commit"

# Delete the old main branch
git branch -D main

# Rename the new branch to main
git branch -m main

# Set remote URL to SSH
git remote set-url origin $SSH_REPO_URL

# Force push the new main branch to GitHub
git push -f origin main

echo "Old commits removed and new branch pushed successfully."
echo "Repository path: $(pwd)"

