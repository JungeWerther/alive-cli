find_config() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.aliverc" ]]; then
            echo "$dir/.aliverc"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

print_rc() {
    local rc_path=$(find_config)
    if [[ -f "$rc_path" ]]; then
        cat "$rc_path"
    else
        echo "No .aliverc file found"
        return 1
    fi
}
