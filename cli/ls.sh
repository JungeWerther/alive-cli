# ls: Display directory structure as a tree with interactive fuzzy searching
# This command provides an interactive directory browser using fzf with file/directory previews
#
# Dependencies:
# - fzf: Fuzzy finder (https://github.com/junegunn/fzf)
# - ls: Directory listing command
# - zed: Text editor for opening files
#
# Usage:
#   list_directory [directory] [subdirectory] [info_function]
#
# Arguments:
#   directory      - Base directory to start browsing from
#   subdirectory   - Optional subdirectory to focus on
#   info_function  - Optional function to generate additional preview info
#
# Features:
# - Interactive fuzzy search of files and directories
# - Rich preview window showing contents/metadata
# - Colored output and emoji indicators
# - Recursive directory navigation
# - Special handling for shell scripts

# Check if required fzf command is available
if ! command -v fzf &> /dev/null; then
    echo -e "\e[31mfzf command not found\e[0m"
    echo -e "\e[33mInstall with: git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install\e[0m"
    exit 1
fi

# Main function to list and browse directory contents
list_directory() {
    local dir="$1"      # Base directory path
    local subdir="$2"   # Optional subdirectory to focus on
    local info_func="$3" # Optional preview info generator
    local items=()

    # Determine which directory path to display
    directory_to_display=""
    case "$subdir" in
        *) directory_to_display="$subdir" ;;
    esac

    # Show current directory in yellow
    echo -e "\e[1;33m[$directory_to_display]\e[0m"

    # Configure preview command for fzf
    # Shows different preview based on whether item is file or directory
    preview_cmd="
            if [ -d {} ]; then
            echo -e '\e[44m\e[37m📁 DIRECTORY CONTENTS\e[0m';
            if [ -z $directory_to_display ]; then
                ls -la {} --color=always
            else
                ls -la '$directory_to_display' --color=always
            fi
        else
            echo -e '\e[44m\e[37m📄 FILE PREVIEW\e[0m';
                head -n 50 {} | grep --color=always .
            fi;
 "

    # Helper function to display directory listing with fzf
    # Parameters:
    #   directory         - Directory to list
    #   display_path     - Path to show in preview
    #   preview_command  - Command to generate preview
    #   transform_preview - Optional transform for preview output
    fzf_list_directory() {
        local directory="$1"
        local display_path="$2"
        local preview_command="$3"
        local transform_preview="$4"

        if [[ -n "$transform_preview" ]]; then
            ls -1a --color=always "${directory}" | fzf \
                --preview "$preview_command | $transform_preview" \
                --layout=reverse \
                --info=inline \
                --border \
                --ansi
        else
            ls -1a --color=always "${directory}" | fzf \
                --preview "$preview_command" \
                --layout=reverse \
                --info=inline \
                --border \
                --ansi
        fi
    }

    # Get user selection through fzf
    selected=$(fzf_list_directory "${subdir:-$dir}" "$directory_to_display" "$($info_func) ${preview_cmd}" "$PREVIEW_TRANSFORM")

    # Exit if nothing selected
    [ -z "$selected" ] && exit 1

    # Build full path from selection
    fullpath="$dir/$selected"

    # Handle the selected item
    if [[ -n "$selected" ]]; then
        echo "$selected"
        if [ -d "$fullpath" ]; then
            # For directories: show directory indicator and recurse
            echo "[DIR] $fullpath"
            alive ls "$fullpath/"
        else
            # For files: show file indicator and handle based on type
            echo "[FILE] $fullpath"
            if [[ "$selected" == *.sh ]]; then
                # Generate documentation for shell scripts
                alive gen documentation "$basepath/$selected"
            fi
            # Open file in editor
            zed "$fullpath"
        fi
    fi
}

# Function to generate metadata preview for files
# Parameters:
#   file - Path to file to generate preview for
generate_preview() {
    local file="$1"
    local preview_output="/tmp/preview_output.txt"

    if [ -f "$file" ]; then
        file "$file" > "$preview_output"
        cat "$preview_output"
    else
        echo "Not a file" > "$preview_output"
        cat "$preview_output"
    fi
}

# Initialize browser from current working directory
list_directory "$PWD" "$2" "echo"
