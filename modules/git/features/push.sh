function help_push() {
    printf "\033[35mfast git push\033[0m -m|--message <commit_message> [-w|--whole-repo]\n"
    echo ""
    echo "Options:"
    echo "  -m, --message     Commit message for the changes being pushed (required)"
    echo "  -w, --whole-repo  Push the entire repository instead of just the current directory (optional)"
    echo "  -h, --help        Show this help message and exit (optional)"
    echo ""
    echo "Description:"
    echo "  Pushes the specified branch to the linked remote repository."
    echo ""
}

current_branch=$(git branch --show-current)
repo_root=$(git rev-parse --show-toplevel)
message=""
whole_repo=0

case "$1" in
    help|-h|--help)
        help_push
        exit 0
        ;;
    -w|--whole-repo)
        whole_repo=1
        shift
        ;;
    -m|--message)
        message="$2"
        shift 2
        ;;
esac

if [ -z "$current_branch" ]; then
    exit 1
fi

if [ -z "$message" ]; then
    echo "Commit message is required." >&2
    exit 1
fi

if [ $whole_repo -eq 1 ]; then
    git add "$repo_root"
    echo "Added whole repository to staging area." >&2
else
    git add .
    echo "Added current directory to staging area." >&2
fi

git commit -m "$message"

if git show-ref --verify --quiet refs/heads/$current_branch; then
    echo "Remote branch found. Pushing on remote branch '$current_branch'." >&2
    git push origin "$current_branch"
else
    echo "The remote branch '$current_branch' does not exist. Creating it." >&2
    git push -u origin "$current_branch"
fi
