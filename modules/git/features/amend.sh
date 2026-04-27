#!/bin/bash

function help_amend() {
    printf "\033[35mfast git amend\033[0m [-m|--message <message>] [-w|--whole-repo] [help|-h|--help]\n" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -m, --message     New commit message for the amended commit (optional)" >&2
    echo "  -w, --whole-repo  Amend the entire repository instead of just the current directory (optional)" >&2
    echo "  -h, --help        Show this help message and exit (optional)" >&2
    echo "" >&2
    echo "Description:" >&2
    echo "  Amends the last commit with the changes in the current directory or the whole repository. " >&2
    echo "  If a new commit message is provided, it will replace the existing one; otherwise, the existing commit message will be retained." >&2
    echo "  The amended commit will be pushed to the remote repository if the current branch has a corresponding remote branch" >&2
    echo "  If no remote branch is found, a new remote branch will be created and the amended commit will be pushed there." >&2
    echo "" >&2
}

current_branch=$(git branch --show-current)
repo_root=$(git rev-parse --show-toplevel)
message=""
amend_message=0
whole_repo=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        help|-h|--help)
            help_amend
            exit 0
            ;;
        -w|--whole-repo)
            whole_repo=1
            shift
            ;;
        -m|--message)
            amend_message=1
            message="$2"
            shift 2
            ;;
    esac
done

if [ -z "$current_branch" ]; then
    exit 1
fi

if [ $amend_message -eq 1 ] && [ -z "$message" ]; then
    echo "Commit message is required." >&2
    exit 1
fi

# Add changes to staging area
if [ $whole_repo -eq 1 ]; then
    git add "$repo_root"
    echo "Added whole repository to staging area." >&2
else
    git add .
    echo "Added current directory to staging area." >&2
fi

echo "" >&2

# Amend the last commit
if [ $amend_message -eq 1 ]; then
    git commit --amend -m "$message"
else
    git commit --amend --no-edit
fi

# Push the amended commit to the remote repository
if git show-ref --verify --quiet refs/heads/$current_branch; then
    echo "Remote branch found. Pushing with lease on remote branch '$current_branch'." >&2
    echo "" >&2
    git push origin "$current_branch" --force-with-lease
else
    echo "The remote branch '$current_branch' does not exist. Creating it." >&2
    echo "" >&2
    git push -u origin "$current_branch"
fi