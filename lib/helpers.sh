# ANSI Color constants - Define terminal color codes for consistent styling
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Markup helpers
# markup: Apply ANSI color styling to text
# @param $1 - ANSI color code to apply
# @param $2 - Text to style
# @return Styled text with color reset
markup() {
  local style=$1
  local text=$2
  echo -e "${style}${text}${NC}"
}

# info: Display informational message in blue
# @param $1 - Message text
message() { markup "$BLUE" "ℹ️  $1"; }

# success: Display success message in green
# @param $1 - Message text
success() { markup "$GREEN" "✅ $1"; }

# warning: Display warning message in yellow
# @param $1 - Message text
warning() { markup "$YELLOW" "⚠️  $1"; }

# error: Display error message in red
# @param $1 - Message text
error() { markup "$RED" "❌ $1"; }

# header: Display header text in bold cyan
# @param $1 - Header text
header() { markup "$BOLD$CYAN" "⚡ $1"; }

# fzf_select: Interactive single selection using fzf
# @param $1 - Prompt text
# @param $2 - Options to select from
# @param $3 - Preview command (optional, defaults to echo)
# @return Selected option
fzf_select() {
  local prompt=$1
  local options=$2
  local preview_cmd=${3:-"echo {}"}

  # If options is empty, ensure we still get the query
  if [[ -z "$options" ]]; then
    options=" "  # Add empty space to prevent fzf from exiting immediately
  fi

  echo "$options" | fzf \
    --height=40% \
    --reverse \
    --prompt="$prompt > " \
    --preview="$preview_cmd" \
    --preview-window=right:50% \
    --print-query \
    --ansi | tail -1
}

# fzf_multi_select: Interactive multiple selection using fzf
# @param $1 - Prompt text
# @param $2 - Options to select from
# @param $3 - Preview command (optional, defaults to echo)
# @return Selected options
fzf_multi_select() {
  local prompt=$1
  local options=$2
  local preview_cmd=${3:-"echo {}"}

  echo "$options" | fzf \
    --multi \
    --height=40% \
    --reverse \
    --prompt="$prompt > " \
    --preview="$preview_cmd" \
    --preview-window=right:50% \
    --ansi
}

# prompt_yn: Yes/No prompt with default No
# @param $1 - Prompt text
# @param $2 - Default answer (optional, defaults to "n")
# @return 0 if Yes, 1 if No
prompt_yn() {
  local prompt=$1
  local default=${2:-"n"}

  while true; do
    printf "%b" "$YELLOW$prompt [y/N]$NC "
    read -r yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*|"") return 1 ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

# find_up: Search for file in current and parent directories
# @param $1 - Filename to search for
# @return Full path to found file or 1 if not found
find_up() {
  local file=$1
  local dir=$PWD

  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/$file" ]]; then
      echo "$dir/$file"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

# ensure_dir: Create directory if it doesn't exist
# @param $1 - Directory path to create
ensure_dir() {
  local dir=$1
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi
}

# load_config: Load .aliverc configuration file
# @return 0 if config loaded, 1 if not found
load_config() {
  local config_file=$(find_up ".aliverc")
  if [[ -f "$config_file" ]]; then
    source "$config_file"
    return 0
  fi
  return 1
}

# list_formatted: Display numbered list with cyan numbers
# @param $@ - List items to display
list_formatted() {
  local items=("$@")
  local i=1
  for item in "${items[@]}"; do
    printf "%b %2d)%b %s\n" "$CYAN" $i "$NC" "$item"
    ((i++))
  done
}

# with_spinner: Execute command with loading spinner
# @param $1 - Message to display
# @param $2 - Command to execute
# @return Command exit status
with_spinner() {
  local message=$1
  local cmd=$2

  echo -n "$message... "
  eval "$cmd" &>/dev/null &
  local pid=$!

  local spin='-\|/'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r$message... ${spin:$i:1}"
    sleep .1
  done
  wait $pid
  local status=$?
  printf "\r$message... "

  if [[ $status -eq 0 ]]; then
    success "done"
  else
    error "failed"
  fi
  return $status
}

# process_template: Process template file with variable substitution
# @param $1 - Template file path
# @param $2 - Output file path
# @param $@ - Variable assignments in key=value format
process_template() {
  local template=$1
  local output=$2
  shift 2
  local vars=("$@")

  cp "$template" "$output"
  for var in "${vars[@]}"; do
    local key=${var%%=*}
    local value=${var#*=}
    sed -i "s|{{$key}}|$value|g" "$output"
  done
}

find_config() {
  local config_file=$(find_up ".aliverc")
  if [[ -f "$config_file" ]]; then
    echo "$config_file"
    return 0
  fi
  return 1
}
