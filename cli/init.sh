# Console output functions
# Message templates
MSG_SEARCH_START_1="\n🔍 \033[1;36mSearching for .aliverc configuration file...\033[0m"
MSG_SEARCH_START_2="📂 Starting search from: \033[1;33m$1\033[0m"
MSG_CHECKING_DIR="🔄 \033[1;90mChecking parent directory: \033[1;90m$1\033[0m"
MSG_CONFIG_FOUND="✨ \033[1;32mFound configuration at: \033[1;33m$1\033[0m"
MSG_NO_CONFIG="❌ \033[1;31mNo configuration file found in parent directories\033[0m"
MSG_CONFIG_CREATED="\n✨ \033[1;32mConfiguration created at: \033[1;33m$1\033[0m"


# Directory traversal functions
is_git_repo() {
    [[ -d "$1/.git" ]]
}

has_config() {
    [[ -f "$1/.aliverc" ]]
}

get_parent_dir() {
    dirname "$1"
}

print_config_found () {
    echo -e "$MSG_CONFIG_FOUND $1"
}

# Selection helper functions
select_with_fzf() {
    local prompt="$1"
    local options="$2"
    local multi="$3"
    if [[ "$multi" == "true" ]]; then
        fzf_multi_select "$prompt" "$options"
    else
        fzf_select "$prompt" "$options"
    fi
}

collect_custom_scripts() {
    local scripts=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        scripts="$scripts\n    \"$line\":"
    done
    echo "$scripts"
}

format_array_items() {
    echo "$1" | sed 's/^/"/;s/$/"/' | tr '\n' ',' | sed 's/,$//'
}


write_config() {
    local root="$1"
    local content="$2"
    echo "$content" > "$root/.aliverc"
}

create_config() {
    # this assumes $r is aliased as pwd in .zshrc

    local selected_root=$r
    [[ -z "$selected_root" ]] && echo "No workspace root selected. Aborting." && return 1

    echo -e "\nDefine custom scripts (one per line, empty line to finish):"
    local custom_scripts=$(collect_custom_scripts)

    local config_content=$(create_config_content "$selected_root" "$test_framework" "$test_env" "$coverage_tool" "$ci_provider" "$linting_tools" "$custom_scripts")
    write_config "$selected_root" "$config_content"
    print_config_created "$selected_root/.aliverc"
    return 0
}

find_config() {
    local dir="$PWD"
    local project_root=""

    echo -e $MSG_SEARCH_START_1

    while [[ "$dir" != "/" ]]; do
        if ! is_git_repo "$dir"; then
            dir=$(get_parent_dir "$dir")
            continue
        fi

        if has_config "$dir"; then
            print_config_found "$dir/.aliverc"
            return 0
        fi

        dir=$(get_parent_dir "$dir")
        print_checking_dir "$dir"
    done

    echo -e $MSG_NO_CONFIG
    read -p "Would you like to create a new workspace configuration in $PWD? [y/N] " answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        project_root="$PWD"
        create_config
    fi

    echo "PROJECT ROOT $project_root"
    return 1
}

find_config
