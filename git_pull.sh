#!/bin/bash

fetch_latest_commit() {
  echo "Fetching the latest commit SHA..."
  response=$(curl -s "https://api.github.com/repos/${GITHUB_USERNAME}/${GITHUB_REPO}/git/refs/heads/master" -H "Authorization: token ${GITHUB_API_TOKEN}" -H "Accept: application/vnd.github.v3+json")
  latest_commit=$(echo "$response" | jq -r '.object.sha')
  echo "$latest_commit"
}

perform_git_pull() {
  latest_commit=$(fetch_latest_commit)
  echo "Latest commit SHA: $latest_commit"
  cd "$GITHUB_REPO" || exit 1
  git pull origin master
  cd .. || exit 1
}

prompt_github_credentials() {
  read -p "Enter your GitHub username: " GITHUB_USERNAME
  read -p "Enter your GitHub API token: " GITHUB_API_TOKEN
  export GITHUB_USERNAME
  export GITHUB_API_TOKEN
}

if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_API_TOKEN" ]; then
  prompt_github_credentials
fi

read -p "Enter your repository name: " GITHUB_REPO
read -p "Enter the timeout in seconds (e.g., 3600 for 1 hour): " TIMEOUT

if [ -d "$GITHUB_REPO" ]; then
  cd "$GITHUB_REPO"
  git config user.name "$GITHUB_USERNAME"
  git config user.email "${GITHUB_USERNAME}@users.noreply.github.com"
  cd .. || exit 1
else
  echo "Cloning GitHub repository..."
  git clone "https://github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git"
fi

while true; do
  perform_git_pull
  sleep "$TIMEOUT"
done
