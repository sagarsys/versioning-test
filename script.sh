#!/usr/bin/env bash

function check_branch() {
    branch=$(git symbolic-ref --short HEAD || git rev-parse --abbrev-ref HEAD)
    if [[ ($branch == "master" || $branch == "develop") ]]
    then
      echo "!! [NOT ALLOWED] rebase cannot be performed on $branch !!"
      exit
    fi
    echo "$branch"
}

function exit_script() {
  echo "Exiting script"
  exit
}

function confirm() {
  # Print confirmation message
  echo "$1"
  echo -n "Proceed? [y/n]: "
  read answer
  if [[ ${answer,,} == 'y' ]]; then
    echo "Updating from remote branch"
    changes=$(git pull origin "$current_branch")
    if [[ $changes == "Already up to date." ]]; then
      # git reset --hard -q
      return 0;
    else
      echo "$changes"
      exit_script
    fi
  else
    exit_script
  fi
}

function get_first_branch_commit_id() {
  sha=$(git merge-base remotes/origin/"$current_branch" develop)
  echo "$sha"
}

function amend_commits() {
    echo "Merging all commits($merge_base) since branch creation into a single commit"
    git reset --soft "$(git merge-base --fork-point master)"
    git commit --verbose --reedit-message=HEAD --reset-author
    git push --force-with-lease
}

# Check current branch => Exit if master or develop
current_branch=$(check_branch)

# Confirm that you want to rebase => All uncommitted changes will be lost
confirm "This will rebase the $current_branch branch? \n Make sure you have committed all your changes, all uncommitted changes will be lost."

# Get the first commit id of branch
merge_base=$(get_first_branch_commit_id)

# Launch rebase on branch with commit id
amend_commits

# Push rebased history to branch
# Checkout develop and pull changes
# Checkout branch
# Rebase develop


#echo "Enter the branch name you wish to rebase"
#read branch
#git checkout "$branch"
#echo "Enter the commit ID [SHA] to start rebasing from (it should be the first commit on the branch to rebase)"
#read SHA
#echo "Pick the first commit and squash the remaining commits"
#git rebase -i "$SHA"
#git push origin "$branch" --force-with-lease
#git checkout develop && git pull origin develop
#git checkout "$branch"
#git rebase develop
