# Define prompt_uninstall function
prompt_uninstall() {
    local path=$1
    if prompt_yn "Do you want to uninstall alive-cli? This will remove $path"; then
        with_spinner "Removing symlink" "sudo rm $path"
        success "Uninstalled successfully"
    else
        warning "Uninstall cancelled"
        exit 0
    fi
}

ask_add_env_local() {
    if prompt_yn "Do you want to create a new .env.local from .env.example?"; then
    cp "$basepath/.env.example" "$basepath/.env.local"

    # Default editors to offer
    local editors=(
        "zed"
        "vim"
        "nvim"
        "code"
        "code-insiders"
    )

    # Allow custom input or selection from defaults
    local editors_list=$(printf "%s\n" "${editors[@]}")
    local editor=$(fzf_select "Select your preferred editor command" "$editors_list")

    [[ -z "$editor" ]] && editor="vim" # Default to vim if no selection
    sed -i "s/^EDITOR=.*$/EDITOR=$editor/" "$basepath/.env.local"

    $editor "$basepath/.env.local"

        success "Environment file created and opened for editing"
    else
        warning "Environment file not created"
        exit 0
    fi
}

main() {
    local current_path=$(pwd)

    install_for_platform() {
        local target_path=$1
        local needs_sudo=$2

        if [[ -L "$target_path" ]]; then
            prompt_uninstall "$target_path"
        else
            local cmd="ln -s $current_path/alive $target_path"
            if [[ "$needs_sudo" == "true" ]]; then
                cmd="sudo $cmd"
            fi
            with_spinner "Installing symlink" "$cmd"
            success "Installation complete"
            ask_add_env_local
        fi
    }

    if grep -q 'debian\|ubuntu' /etc/os-release; then
        install_for_platform "/usr/bin/alive" true
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        install_for_platform "/usr/local/bin/alive" true
    elif [[ -e "/data/data/com.termux" ]]; then
        install_for_platform "$PREFIX/bin/alive" false
    else
        error "Unsupported operating system"
        exit 1
    fi
}

main "$@"
