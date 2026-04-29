#!/bin/bash

venv_dir="$1"
shift

function help_create() {
    printf "\033[35mfast venv create\033[0m -n|--name <env_name> -m|--module <module_name> [-m|--module <module_name> ...] [-ml|--modules-list <module1 module2 ...>]\n" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  -n, --name           Name of the virtual environment to create (required)" >&2
    echo "  -m, --module         Python module to install in the virtual environment (can be specified multiple times for multiple modules, optional)" >&2
    echo "  -ml, --modules-list  Space-separated list of Python modules to install in the virtual environment (optional)" >&2
    echo "  -h, --help           Show this help message (optional)" >&2
    echo "" >&2
    echo "Description:" >&2
    echo "  Creates a new Python virtual environment with the specified name and installs the specified Python modules in it." >&2
    echo "  The virtual environment will be created in '$venv_dir/<env_name>'." >&2
    echo "  The specified Python modules can be provided either through multiple -m|--module options or as a space-separated list through the -ml|--modules-list option." >&2
    echo "  If both options are used, the modules from both options will be combined and installed in the virtual environment." >&2
    echo "  The script will check if the specified Python modules are available in the current Python environment before creating the virtual environment." >&2
    echo "  If any of the specified modules are not found, an error message will be displayed and the virtual environment will not be created." >&2
    echo "" >&2
}

module_list=()
name=""
already_activated_venv=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        help|-h|--help)
            help_create
            exit 0
            ;;
        -n|--name)
            name="$2"
            shift 2
            ;;
        -m|--module)
            module_list+=("$2")
            shift 2
            ;;
        -ml|--modules-list)
            for module in $2; do
                module_list+=("$module")
            done
            shift 2
            ;;
        *)
            echo "Unknown option: '$1'. Use 'venv create --help' for more information." >&2
            help_create
            exit 127
            ;;
    esac
done

# Validate the environment name
if [ -z "$name" ]; then
    echo "Environment name is required. Use 'venv create --help' for more information." >&2
    exit 1
fi

# Validate the module list, ensuring that at least one module is provided either through individual options or a comma-separated list
if [ ${#module_list[@]} -eq 0 ] && [ -z "$modules_list" ]; then
    echo "At least one module is required. Use 'venv create --help' for more information." >&2
    exit 1
fi

# For each module provided, check if the python module exists
for module in "${module_list[@]}"; do
    if ! python3 -c "import $module" &> /dev/null; then
        echo "Python module '$module' not found. Please make sure it is installed and available in the current Python environment." >&2
        exit 1
    fi
done

# Check if the virtual environment is currently active and store its name if it is
if [ -n "$VIRTUAL_ENV" ]; then
    already_activated_venv=$(basename "$VIRTUAL_ENV")
    deactivate
fi

# Create the virtual environment and install the specified modules
mkdir -p "$venv_dir/$name"
python3 -m venv "$venv_dir/$name"
source "$venv_dir/$name/bin/activate" 
pip install --upgrade pip
for module in "${module_list[@]}"; do
    pip install "$module"
done
deactivate
echo "Virtual environment '$name' created successfully with the specified modules installed." >&2

# If there was a virtual environment that was already activated before running the create command, reactivate it
if [ -n "$already_activated_venv" ]; then
    source "$venv_dir/$already_activated_venv/bin/activate"
    echo "Reactivated previously active virtual environment '$already_activated_venv'." >&2
fi