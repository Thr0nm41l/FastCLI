#!/bin/bash

function help_rebase() {
    printf "\033[35mfast git rebase\033[0m [-m|--master-branch <master_branch>] [-r|--resolve-strategy <ours|theirs|none>] [-p|--push] [help|-h|--help]\n" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -m, --master-branch       Specify the master branch to rebase onto (optional, defaults to the main branch of the remote repository)" >&2
    echo "  -r, --resolve-strategy    Specify the conflict resolution strategy to use during the rebase process (optional, defaults to 'theirs')" >&2
    echo "                             Valid options are 'ours', 'theirs', and 'none'" >&2
    echo "  -p, --push                Push the rebased branch to the remote repository after a successful rebase (optional)" >&2
    echo "  -h, --help                Show this help message and exit (optional)" >&2
    echo "" >&2
    echo "Description:" >&2
    echo "  Rebases the current branch onto the specified master branch. If no master branch is specified, it defaults to the main branch of the remote repository." >&2
    echo "  The script will switch to the master branch, pull the latest changes, switch back to the current branch, and perform a rebase onto the master branch using the specified conflict resolution strategy." >&2
    echo "  If the push option is enabled, it will push the rebased branch to the remote repository after a successful rebase." >&2
    echo "" >&2
}

current_branch=$(git branch --show-current)
master_branch=""
resolve_strategy="-X theirs"
push=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        help|-h|--help)
            help_rebase
            exit 0
            ;;
        -m|--master-branch)
            master_branch="$2"
            shift 2
            ;;
        -r|--resolve-strategy)
            resolve_strategy="$2"
            shift 2
            ;;
        -p|--push)
            push=1
            shift
            ;;
        *)
            echo "Unknown option: '$1'. Use 'git rebase-branch --help' for more information." >&2
            help_rebase
            exit 127
            ;;
    esac
done

# Handle resolve strategy, defaulting to 'theirs' if an invalid option is provided or if no option is provided
case "$resolve_strategy" in
    ours)
        resolve_strategy="-X ours"
        ;;
    theirs)
        resolve_strategy="-X theirs"
        ;;
    none)
        resolve_strategy=""
        ;;
    *)
        echo "Defaulting to 'theirs', favoring incoming changes." >&2
        resolve_strategy="-X theirs"
        ;;
esac

# Check if the current branch is valid
if [ -z "$current_branch" ]; then
    echo "No current branch found. Please ensure you are in a valid Git repository." >&2
    exit 1
fi 

# Check if the master branch is valid, if not provided, default to the main branch of the remote repository
if [ -n "$master_branch" ]; then
    if ! git show-ref --verify --quiet "refs/heads/$master_branch"; then
        echo "Master branch '$master_branch' not found. Please provide a valid master branch." >&2
        exit 127
    fi
else
    master_branch="$(git remote show origin | awk '/HEAD branch/ {print $NF}')"
    if [ -z "$master_branch" ]; then
        echo "Could not determine the default master branch. Please provide a master branch using the -m option." >&2
        exit 127
    fi
fi

# Check if the master branch is the same as the current branch
if [ "$master_branch" == "$current_branch" ]; then
    echo "The master branch '$master_branch' is the same as the current branch '$current_branch'." >&2
    echo "Please provide a different master branch to rebase onto." >&2
    exit 127
fi

# Switch to the master branch and pull the latest changes
git checkout "$master_branch"
git pull origin "$master_branch"
if [ $? -ne 0 ]; then
    echo "Failed to pull the latest changes from the master branch '$master_branch'." >&2
    exit 1
fi

# Switch back to the current branch and rebase it onto the master branch
git checkout "$current_branch"
git rebase $resolve_strategy "$master_branch"
if [ $? -ne 0 ]; then
    echo "Rebase failed. Please resolve any conflicts and continue the rebase process manually." >&2
    exit 1
fi

# If the push option is enabled, push the rebased branch to the remote repository
if [ $push -eq 1 ]; then
    if git show-ref --verify --quiet refs/heads/$current_branch; then
        echo "Remote branch found. Pushing rebased branch '$current_branch' to remote repository." >&2
        echo "" >&2
        git push origin "$current_branch" --force-with-lease
    else
        echo "No remote branch found. Creating a new remote branch '$current_branch' and pushing the rebased branch to the remote repository." >&2
        echo "" >&2
        git push origin "$current_branch"
    fi
fi