git add .

echo -e "\e[1;35m🔍 📂 (git add .) \e[0m$(pwd)"

# Array of commit prefixes
prefixes=("fix:" "feature:" "try:" "style:" "merge:" "docs:" "refactor:" "perf:" "test:" "chore:")

# Use fzf to select prefix
prefix=$(printf "%s\n" "${prefixes[@]}" | fzf --height 40% --reverse --prompt=$'\e[1;36mSelect commit prefix\e[0m > ')

# Exit if no selection made
if [ -z "$prefix" ]; then
    echo -e "\e[1;31m❌ No prefix selected, exiting\e[0m"
    exit 1
fi
# Ask for commit message
echo -e -n "\e[1;33m> $prefix \e[0m"
read message

# Combine prefix and message
full_message="$prefix $message"

echo -e "\e[1;32m🦄 committing changes with message: \e[1;37m$full_message\e[0m"

# Execute git commit
git commit -m "$full_message"

# Get all remote branches and add "Exit" option
# Get all remote branches and format them with commit info
# Get only upstream tracking branches
branches=$(git for-each-ref --format='%(upstream:short)' refs/heads/ | grep '^origin/' | sed 's/origin\///' | while read branch; do
  if [[ ! "$branch" =~ "HEAD" ]]; then
    commit_info=$(git log -1 --pretty=format:"%C(yellow)%h%Creset | %C(green)%cr%Creset | %C(blue)%s%Creset" origin/$branch 2>/dev/null)
    if [ ! -z "$commit_info" ]; then
      echo "$branch|$commit_info"
    fi
  fi
done | sed 's/|/ | /')

# Add Exit option and get user selection using exact match on first column
selected_branch=$(printf "%s\nExit" "$branches" | column -t -s'|' -o' | ' | fzf --ansi --height 40% --reverse --prompt=$'\e[1;34mSelect branch to merge into (or type Exit)\e[0m > ' --header-lines=0 --exact --nth=1 | awk '{print $1}')
# Exit if "Exit" selected or no selection made
if [ "$selected_branch" = "Exit" ] || [ -z "$selected_branch" ]; then
    echo -e "\e[1;33m🚪 No branch selected for merge, exiting merge step\e[0m"
    exit 0
fi

echo -e "\e[1;36m🌀 Merging into \e[1;37m$selected_branch\e[0m..."

current_branch=$(git branch --show-current)

git checkout $selected_branch

# git pull origin $selected_branch
# # Fetch updates from remote
git fetch origin $selected_branch

# Get commit differences between local and remote
changes=$(git rev-list --count HEAD..origin/$selected_branch)

if [ $changes -gt 0 ]; then
    echo -e "\e[1;31m⚠️ Remote has $changes new commit(s). Pulling changes...\e[0m"
    git pull origin $selected_branch
else
    echo -e "\e[1;32m✅ Local branch is up to date with remote\e[0m"
fi
echo -e "\e[1;35m🔗 Merging $current_branch into $selected_branch\e[0m"
git merge $current_branch

echo -e -n "\e[1;35m🎯 Push changes to $selected_branch? [y/N] \e[0m"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    git push
else
    echo -e "\e[1;31m💤 Changes not pushed to remote\e[0m"
fi

git checkout $current_branch
echo -e "\e[1;32m🌈 All done! Back on \e[1;37m$current_branch\e[0m ✨"
