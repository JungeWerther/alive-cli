#!/bin/bash
#/templates/template.sh
#
# Template script
# Usage: alive gen template <name>

notes_path="$basepath/notes"
ensure_dir "$notes_path"

# Get list of existing notes or default to empty if none exist
existing_notes=$(ls "$notes_path"/*.md 2>/dev/null | sed 's|.*/\(.*\)\.md|\1|' || echo "")

# Allow selecting existing note or entering new note name
selected_note=$(echo "$existing_notes" | fzf_select "Select or create note (type new name if not found)" \
  "$existing_notes" \
  "cat $notes_path/{}.md 2>/dev/null || echo 'New note'" )

file_name="${selected_note}.md"
if [[ ! -f "$notes_path/$file_name" ]]; then
    echo "<!-- Created: $(date) -->" > "$notes_path/$file_name"
    cat "$basepath/symbols/:note" >> "$notes_path/$file_name"
    success "Created new note at $file_name"
fi

$EDITOR "$notes_path/${selected_note}.md"
