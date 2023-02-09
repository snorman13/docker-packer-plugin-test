#!/bin/bash

read -r -a syncList <<< "$SYNC_LIST"

sync_files() {
  if [ ! -d "./base_repository" ]; then
    echo "ERROR: unable to access base repository"
    exit 1
  fi

  if [ ! -d "./target_repository" ]; then
    echo "ERROR: unable to access target repository"
    exit 1
  fi

  # Configure git
  echo "INFO: configuring git"
  git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
  git config --global user.name "github-actions[bot]"

  # Check for existing remote branch
  branchExists=$(git -C ./target_repository ls-remote --heads origin | grep "$BRANCH_NAME")

  # Checkout existing branch if it exists
  if [ -n "$branchExists" ]; then
    echo "INFO: checking out existing branch $BRANCH_NAME"
    git -C ./target_repository checkout "$BRANCH_NAME"
  else
    echo "INFO: creating new branch $BRANCH_NAME"
    git -C ./target_repository checkout -b "$BRANCH_NAME"
  fi

  # Sync list of files to target repo
  for item in "${syncList[@]}"; do
    echo "INFO: syncing $item"
    cp -rf "./base_repository/$item" ./target_repository/
  done

  # Check for any changes
  status=$(git -C ./target_repository status | grep 'git add')
  if [ -z "$status" ]; then
    echo "INFO: no changes to push"
    exit 0
  fi
  
  # Commit and push
  git -C ./target_repository add .
  git -C ./target_repository commit -m "$COMMIT_MESSAGE"
  git -C ./target_repository push -u origin "$BRANCH_NAME"

  # Check for existing PR and create if it doesn't exist
  cd ./target_repository || exit 1
  echo "INFO: checking for existing PR"
  prContent=$(gh pr list --head "$BRANCH_NAME")
  if [[ $prContent != *"$BRANCH_NAME"* ]]; then
    gh pr create --title "$PR_TITLE" --body "Automated PR to sync files from base/template repository."
  fi
}

sync_files
