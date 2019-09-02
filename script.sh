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
    return 0;
  else
    exit_script
  fi
}

function get_first_branch_commit_id() {
  sha=$(git merge-base remotes/origin/"$current_branch" develop)
  echo "$sha"
}

function get_commit_type() {
    echo "* Enter the development type (feat, fix, chore, refactor, test, docs, build)"
    read type
    local TYPE=${type,,}
    if [[ ($TYPE != "feat" && $TYPE != "fix" && $TYPE != "chore" && $TYPE != "test"
        && $TYPE != "refactor" && $TYPE != "docs" && $TYPE != "build" ) ]]
    then
      echo "Invalid type, please insert a valid type" &&
      get_commit_type
    fi
    echo $TYPE
}

function get_commit_msg() {
    echo "* Enter a commit message describing the development"
    read message
    local MSG=${message,,}
    if [[ ! $MSG ]]
    then
      echo "Invalid message, please insert a valid message" &&
      get_commit_message
    fi
    echo $MSG
}

function get_commit_scope() {
    echo "Enter an optional scope for the development [leave blank for no scope]"
    read scope
    local SCOPE=${scope,,}
    echo $SCOPE
}

function get_commit_desc() {
    echo "Enter an optional description for the development [leave blank for no description]"
    read desc
    local DESC=${desc,,}
    echo $DESC
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

echo "Running script.............................."
# Check current branch => Exit if master or develop
#current_branch=$(check_branch)
#echo "$current_branch"

# Confirm that you want to rebase => All uncommitted changes will be lost
#confirm "This will rebase the $current_branch branch? \n Make sure you have committed all your changes, all uncommitted changes will be lost."

# Get the first commit id of branch
#merge_base=$(get_first_branch_commit_id)
#echo "$merge_base"

# Launch rebase on branch with commit id
echo "Getting amended commit message"
msg=$(get_commit_msg)
echo $msg
#amend_commits "$message"

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
