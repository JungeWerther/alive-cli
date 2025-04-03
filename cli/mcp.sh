#!/bin/bash

# Constants
readonly PARSER_DIR="$HOME/sites/vparser"
readonly BANNER="\033[1;36m╔═~═════~═════~═════~════╗\n║ 🌈  WILD CLI BUFFER  🌈   \n╚═~═════~═════~═════~════╝\033[0m"
readonly WILDNESS_BANNER="\033[1;35m╔═~════~════~════~════╗\n║ 🌟✨ PURPLE CLI ✨🌟  \n╚═~════~════~════~════╝\033[0m"

# Pure functions
is_word_boundary() {
    local char="$1"
    [[ "$char" == " " ]] || [[ "$char" == $'\n' ]]
}

is_buffer_not_empty() {
    local buf="$1"
    [[ -n "${buf// }" ]]
}

# Side effects
process_buffer() {
    local buf="$1"

    # Clear screen and move to home position
    clear

    # Draw input section on left
    echo -e "$BANNER"
    echo -e "\033[1;36mInput Buffer:\033[0m"
    echo -e "$buf"
    echo "$buf " >> "$BASEPATH/state.alive" # Save buffer to state file

    Draw output section
    echo -e "\n$WILDNESS_BANNER"
    echo -e "\033[1;35mProcessed Output:\033[0m"

    # # Display content of alive state
    # if [ -f "$BASEPATH/state.alive" ]; then
    #     cat "$BASEPATH/state.alive"
    # else
    #     echo -e "\033[0;31mNo state file found\033[0m"
    # fi

    # Capture non-verbose Rust output
    # local output
    # if output=$(cargo run --quiet 2>/dev/null); then
    #     # Calculate width for right alignment
    #     term_width=$(tput cols)
    #     buffer_lines=($output)

    #     # Right align each line with ANSI padding
    #     for line in "${buffer_lines[@]}"; do
    #         printf "%*s\n" $term_width "$line"
    #     done
    # fi
}

read_char() {
    local char
    IFS= read -r -N1 char
    echo "$char"
}

process_input() {
    local buffer=""
    local char

    while char=$(read_char); do
        buffer+="$char"
        if is_word_boundary "$char"; then
            if is_buffer_not_empty "$buffer"; then
                process_buffer "$buffer"
            fi
            buffer=""
        fi
    done

    if is_buffer_not_empty "$buffer"; then
        process_buffer "$buffer"
    fi
}

# Main loop
while true; do
    process_input
done
