#!/bin/zsh

# constants

spaces_dir="$HOME/sites/metta-helpers/spaces"

get_context() {
    cat "$spaces_dir/context.metta"
}

write_to_bottom() {
    echo "$@" >> "$spaces_dir/context.metta"
}



# functions
banner() {
    printf "%b" "$1\n" >&2
}

debug_writer() {
    local debug_msg=$1
    local tag=$2
    [[ -z "$tag" ]] && tag="DEBUG"
    local debug_color="\033[35m"
    local reset_color="\033[0m"

    echo -e "${debug_color}[${tag}]${reset_color} $debug_msg" >&2
}

with_markup() {
    echo -e "$execute_markup"
    "$@"
    echo -e "$complete_top"
    echo -e "$complete_middle"
    echo -e "$complete_bottom"
}

run_ag() {
    ZDOTDIR=$HOME zsh -i -c "$@"
}

maybe_searchterm() {
    local entered_term
    local search_term="$1"

    if [[ -z "$1" ]]; then
        echo -e "$prompt_markup"
    else
        if [[ $search_term == "q" ]]; then
            echo "thanks"
            break
        elif [[ $search_term == "w" ]]; then
            read -r entered_term < /dev/tty
            echo "$entered_term"
        else
            echo "$search_term"
        fi
    fi
}

escape_jq() {
    local input=$1
    # Remove special characters that could interfere with jq
    # echo "$input" | sed 's/["\]/\\&/g' | sed 's/[^[:print:]]/\\&/g'
    printf '%s' "$input" | sed -E 's/[^[:print:]]//g' | sed -E 's/[&|;<>()$`\\"]//g' | tr -cd '[:alnum:][:space:]._-'
    # echo "hi you"
}

readifnot() {
    local query="$1"
    local firstrun="$2"
    local debugmsg="$3"

    if [[ -n "$query" && "$firstrun" != "0" ]]; then
        debug_writer "$debugmsg" "search_function"
        echo "$query"
    else
        debug_writer "$query" "search_function"
        read -r reply && echo "$reply"
        # input="$(cat $context | fzf)" >&2
        # echo $input
    fi
}

search_function() {
    local query="$1"
    local debug_writer="$2"
    local first_run="1"

    while true; do
        debug_writer "Processing term" "query"

        filtered_term=$(readifnot "$query" "$first_run" "Using input argument")
        first_run="0"

        debug_writer "Processed term: $filtered_term" "search_function"
        ag "$filtered_term"
    done
}


process_input() {
    local input=$1

    debug_writer "$input" "input"

    if command -v zsh >/dev/null 2>&1; then

        local search_term=$(maybe_searchterm "$input")
        local filtered_term=$(escape_jq "$search_term")

        banner "$dark_chaos"
        debug_writer "$filtered_term" "filtered_term"

        with_markup run_ag "$(typeset -f search_function debug_writer readifnot banner); search_function \"$filtered_term\" debug_writer"

    else
        echo "zsh not found on system"
    fi
}



# accept function passed as command. e.g. 'alive buffer ls'
shift

while true; do
    space=get_context

    input="$("$space" | fzf --ansi --print-query --preview 'alive ag on {} | fold -w 60' | tail -1)"

    if [[ -z "$input" ]]; then
        echo "Program terminated"
        exit 0
    fi

    banner "$dark_magic_banner"
    process_input "$input" "$get_context"
done
