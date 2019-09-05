#!/usr/bin/env bash
message=$1 # Get commit message from cli argument

function exit_script() {
  echo "Exiting script"
  exit
}

function check_branch() {
    branch=$(git symbolic-ref --short HEAD || git rev-parse --abbrev-ref HEAD)
    if [[ ($branch == "master" || $branch == "develop") ]]
    then
      echo "!! [NOT ALLOWED] rebase cannot be performed on $branch !!"
      exit_script
    fi
    echo "$branch"
}

function confirm() {
  # Print confirmation message
  printf "%s" "$1"
  echo -n "Proceed? [y/n]: "
  read answer
  if [[ ${answer,,} == 'y' ]]; then
    return 0;
  else
    exit_script
  fi
}

function get_first_branch_commit_id() {
  sha=$(git merge-base remotes/origin/"$current_branch" develop)
  echo "$sha"
}

function amend_commits() {
    echo "Amend $1"
    local message=$1
    echo "Merging all commits($merge_base) since branch creation into a single commit"
    git reset --soft "$merge_base" # since we always start a feature from develop branch
    git add .
    git commit -am "$message"
    git push origin "$current_branch" --force-with-lease
}

function merge_develop() {
    echo "Merging with develop."
    git checkout develop
    git reset --hard -q
    git pull origin develop -q
    git checkout "$current_branch"
    git rebase develop
    git push origin "$current_branch" --force-with-lease
    git checkout develop
    git merge "$current_branch"
    git push origin develop
}

echo "Performing git updates..."
# Exit script if no message provided
if [[ ! $message ]]
then
  echo "No commit message provided"
  exit_script
fi

# Check current branch => Exit if master or develop
current_branch=$(check_branch)
echo "Current branch: $current_branch"

# Confirm that you want to rebase => All uncommitted changes will be lost
confirm "This will rebase the '$current_branch' branch? \n Make sure you have committed all your changes, all uncommitted changes will be lost."

# Get the first commit id of branch
merge_base=$(get_first_branch_commit_id)

# Launch rebase on branch with commit id
amend_commits "$message"

# Checkout develop and pull changes
merge_develop
