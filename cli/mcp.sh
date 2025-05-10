#!/bin/bash

readonly BANNER="
${BOLD}${BLUE}╔══════════════════════════════════════╗${RESET}
${BOLD}${BLUE}║ ${GREEN}Welcome to the ${CYAN}ALIVE${GREEN} CLI Tool    ${BLUE}║${RESET}
${BOLD}${BLUE}║ ${YELLOW}Start typing to begin...            ${BLUE}║${RESET}
${BOLD}${BLUE}╚══════════════════════════════════════╝${RESET}
"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly YELLOW='\033[1;33m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# Constants
readonly PARSER_DIR="$HOME/sites/vparser"
readonly STATEFILE="$BASEPATH/state.alive"

clear

# Pure functions
is_word_boundary() {
    local char="$1"
    [[ "$char" == " " ]] || [[ "$char" == $'\n' ]] || [[ "$char" == $'\x15' ]]
}

is_buffer_not_empty() {
    local buf="$1"
    [[ -n "${buf// }" ]]
}

render_tui() {
    local state="$1"

    # Draw fancy border
    # Get terminal size
    local TERM_WIDTH=$(tput cols)
    local TERM_HEIGHT=$(tput lines)

    # # Draw top border
    # printf "${BLUE}╔"
    # printf "═%.0s" $(seq 1 $((TERM_WIDTH-1)))

    # Draw input section
    printf "\n${BLUE}║${RESET} ${state}"

    # # Draw remaining vertical lines
    # for ((i=3; i<TERM_HEIGHT; i++)); do
    #     printf "\n${BLUE}║${RESET}"
    # done

    # Draw bottom border
    printf "\n${BLUE}╚"
    printf "═%.0s" $(seq 1 $((TERM_WIDTH-1)))
    printf "\n"
    }

read_state() {
    while IFS= read -r line; do
        printf "${BLUE}║${CYAN}%s${RESET}\n" "$line"
    done < "$STATEFILE"
}

# Side effects
process_buffer() {
    local buf="$1"

    # Clear screen and move to home position
    clear

    # Draw input section on left
    echo "$buf " >> "$BASEPATH/state.alive" # Save buffer to state file
    # ANSI escape codes for colors and styling
    #

    state=$(read_state)

    render_tui "$state"
}

read_char() {
    local char
    IFS= read -r -N1 char
    echo "$char"
}

process_input() {
    local buffer=""
    local char

    echo -e "$BANNER"
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


while true; do
    process_input
    cat $BASEPATH/state.alive > alive embed
done
