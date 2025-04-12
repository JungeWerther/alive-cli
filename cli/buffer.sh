#!/bin/zsh

local evil_banner="\033[31m💀 ᕙ(⇀‸↼‶)ᕗ\033[0m the dark ritual begins \033[31mᕙ(⇀‸↼‶)ᕗ 💀\033[0m"
local dark_magic_banner="\033[35m╔══════════════════════════════════════════╗\033[0m\n\033[35m║\033[1;36m    ＳＥＡＲＣＨ ＴＡＭＡＧＯＴＣＨＩ    \033[35m║\033[0m\n\033[35m╚══════════════════════════════════════════╝\033[0m\n\033[1;33m(づ｡◕‿‿◕｡)づ \033[1;31m*:･ﾟ✧ \033[1;32mPREPARING DARK MAGIC\033[1;31m ✧ﾟ･: \033[1;33m*\033[0m\n\033[1;34m        ▀▄   ▄▀   \033[0m\n\033[1;35m     ▄█▀███▀█▄    \033[0m\n\033[1;31m    █▀███████▀█   \033[0m\n\033[1;32m    █─█▀▀▀▀▀█─█   \033[0m"

local prompt_markup="\033[1;36m→ Enter search term (or 'q' to quit):\033[0m"
local execute_markup="\033[1;33m༼ つ ◕益◕ ༽つ \033[1;31m⚡⚡\033[1;32m executing dark search ritual \033[1;31m⚡⚡\033[0m"

local complete_top="\033[1;34m✧･ﾟ: *✧･ﾟ:* ⋆꧂ *:･ﾟ✧*:･ﾟ✧\033[0m"
local complete_bottom="\033[1;35m⋆⭒✼⋆.｡.:*☽⋆⭒*｡.❀.｡.:*☽⋆⭒✼⋆\033[0m"
local complete_middle=""

local happy_zsh_message="(⌐■_■)⊃━☆ﾟ.*･｡ﾟ ZSH DETECTED! POWER OVERWHELMING!"
local sad_zsh_message="\033[31m╔════════════ ZSH NOT FOUND ════════════╗\n║  (;´༎ຶД༎ຶ\`) THE DARKNESS FADES...      ║\n║  \033[34m▄█▀█▀█▄▄█▀█▀█▄▄█▀█▀█▄▄█▀█▀█▄\033[31m  ║\n║  \033[34m███████████████████████████\033[31m  ║\n║  \033[34m▀█████████████████████████▀\033[31m  ║\n║  \033[34m─▄▀▀▀▀▄─█████─▄▀▀▀▀▄─█████\033[31m  ║\n╚══════════════════════════════════╝\033[0m"
local happy_ag_message="(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧ AG FOUND! LET THE SEARCH BEGIN!"
local sad_ag_message="\033[31m╔═══════════ AG NOT FOUND ═══════════╗\n║ ( ╥﹏╥) THE VOID CONSUMES ALL...    ║\n║ \033[35m▐▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▌\033[31m ║\n║ \033[35m▐  THE SEARCH CANNOT CONTINUE  ▌\033[31m ║\n║ \033[35m▐▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▌\033[31m ║\n║     ヽ(´□｀。)ﾉ                   ║\n╚══════════════════════════════════╝\033[0m"
local dark_chaos="\033[38;5;203m⚔️⛧⚡️ ʕ•̀ω•́ʔ✧ the dark side beckons ʕ•̀ω•́ʔ✧⚡️⛧⚔️\n\n\n\n\033[38;5;218m      ┻━┻ ︵ヽ(⚈□⚈)ﾉ︵ ┻━┻\033[0m\n\n\033[38;5;223m    ⚡️(ﾉಥДಥ)ﾉ︵┻━┻･/︵/(x.x)\\︵\\･┻━┻⚡️\033[0m\n\n\033[38;5;159m         ▄︻̷̿┻̿═━一 ⌐╦╦═─\033[0m\n\n\033[38;5;156m    🔥ᕙ( ︡'︡益'︠)ง🔥 unlimited power!!!\033[0m\n\n\033[38;5;153m         ┛◉Д◉)┛彡┻━┻ ┻━┻\033[0m\n\n\033[38;5;203m⚔️⛧⚡️ ʕ•̀ω•́ʔ✧ chaos reigns supreme ʕ•̀ω•́ʔ✧⚡️⛧⚔️\033[0m"

local zsh_check="[[ \"\$SHELL\" == *\"zsh\"* ]]"
local ag_check="command -v ag >/dev/null 2>&1"

debug_writer() {
    local debug_msg=$1
    local tag=$2
    [[ -z "$tag" ]] && tag="DEBUG"
    local debug_color="\033[35m"
    local reset_color="\033[0m"

    echo -e "${debug_color}[${tag}]${reset_color} $debug_msg"
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

check_predicate() {
    local predicate=$1
    local happy_msg=$2
    local sad_msg=$3
    if eval "$predicate"; then
        echo -e "\033[32m$happy_msg\033[0m\n"
        return 0
    else
        echo -e "\033[32m$sad_msg\033[0m\n"
        return 1
    fi
}

check_zsh() {
    # Function to map predicates to tamagotchi states
    # Check ZSH
    check_predicate "$zsh_check" \
        "$happy_zsh_message" \
        "$sad_zsh_message"

    # Check AG
    check_predicate "$ag_check" \
        "$happy_ag_message" \
        "$sad_ag_message"

    # Return overall status
    eval "$zsh_check" && eval "$ag_check"
}

escape_jq() {
    local input=$1
    # Remove special characters that could interfere with jq
    # echo "$input" | sed 's/["\]/\\&/g' | sed 's/[^[:print:]]/\\&/g'
    printf '%s' "$input" | sed -E 's/[^[:print:]]//g' | sed -E 's/[&|;<>()$`\\"]//g' | tr -cd '[:alnum:][:space:]._-'

    # echo "hi you"
}

process_input() {
    local input=$1

    debug_writer "$input" "input"

    if check_zsh; then
        echo "Already in zsh"
        ag "$input"
    elif command -v zsh >/dev/null 2>&1; then

        while true; do

            printf "%b" "$evil_banner\n"

            local search_term=$(maybe_searchterm "$input")
            local filtered_term=$(escape_jq "$search_term")

            search_function() {
                local query="$1"
                local debug_writer="$2"
                local first_run="1"

                while true; do
                    debug_writer "Processing term" "query"

                    # Use first argument only on first iteration
                    if [[ -n "$query" && "$first_run" != "0" ]]; then
                        debug_writer "Using input argument" "search_function"
                        filtered_term="$query"
                    else
                        # Prompt for input on subsequent iterations
                        debug_writer "$query" "search_function"
                        read -r filtered_term
                    fi

                    first_run="0"
                    debug_writer "Processed term: $filtered_term" "search_function"
                    ag "$filtered_term"
                done
            }

            printf "%b" "$dark_chaos\n"
            debug_writer "$filtered_term" "filtered_term"

            with_markup run_ag "$(typeset -f search_function debug_writer); search_function \"$filtered_term\" debug_writer"


        done
    else
        echo "zsh not found on system"
    fi
}

while true; do
    input=$(ls | fzf)

    echo "$input"
    echo -e "$dark_magic_banner"

    process_input "$input"
done
