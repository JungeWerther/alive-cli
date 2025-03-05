# Check if editor is Zed
if [[ ! "$EDITOR" =~ "zed" ]]; then
    error "This command only works with Zed editor"
    exit 1
fi

config_path=~/.config/zed/settings.json
cp $config_path $config_path.bak

has_lsp_lang=$(cat $config_path | sed 's/\/\/.*$//' | jq -r 'has("lsp") and has("languages")')
if [ "$has_lsp_lang" = "true" ]; then
    settings_string=$(cat $config_path | sed 's/\/\/.*$//' | jq 'del(.lsp, .languages)')
    echo "$settings_string" > "$config_path"
    message "Disabled Deno LSP configuration"
else
    settings_string=$(cat $config_path | sed 's/\/\/.*$//')
    deno_settings=$(cat $basepath/symbols/:deno)
    merged_settings=$(echo "$settings_string" | jq ". + $deno_settings")
    echo "$merged_settings" > "$config_path"
    success "Enabled Deno LSP configuration"
fi
