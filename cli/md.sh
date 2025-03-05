#!/bin/bash
#/md.sh
#
# Lists existing notes, converts one into markdown
# Usage: alive md <note?>

file_name="$2"

if [ -z "${file_name// }" ]; then
    # List files and create selection interface
    files=($(ls "$basepath/notes/"))
    selected=0
    tput clear
    while true; do
        echo "📝 Select a note to convert to HTML"
        echo ""
        echo -e "\033[48;5;33m📚 alive/notes \033[0m"

        for i in "${!files[@]}"; do
            if [ $i -eq $selected ]; then
                echo "◉ ${files[$i]}"
            else
                echo "  ${files[$i]}"
            fi
        done

        echo ""
        echo "---"
        echo "Use j/k to move, enter to select, q to cancel"

        read -rsn1 key
        case "$key" in
            j) ((selected < ${#files[@]} - 1)) && ((selected++));;
            k) ((selected > 0)) && ((selected--));;
            q) echo "Cancelled"; exit 0;;
            "") file_name="${files[$selected]}"; break;;
        esac
        tput clear
    done
fi

echo "✨ Copying $file_name as HTML to clipboard..."
pandoc -f markdown -t html "$basepath/notes/$file_name" | xclip -selection clipboard -sel clip -t text/html

echo "📋 HTML copied to clipboard"



# $EDITOR "$basepath/cli/templates/$file_name"
