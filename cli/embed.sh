shift
val="$@"

function get_ollama_embeddings() {
    curl -s http://localhost:11434/api/embed -d "{\"model\": \"snowflake-arctic-embed:22m\", \"input\": \"$val\"}"
}

function key_get() {
    local key=$2
    echo "$1" | jq -r $key
}

function join() {
    local dict1=$1
    local dict2=$2
    echo "$dict1" "$dict2" | jq -s add
}

# Function to format embeddings array
function flatten_embeddings_array() {
    local embeddings=$@
    echo "$embeddings" | jq -c '.embeddings |= flatten'
    # echo $input
}

# Function to store embeddings in DuckDB
function embeddings() {
    # Get embeddings response from function
    embeddings_response=$(get_ollama_embeddings)

    # Extract just the embedding array
    embeddings=$(key_get $embeddings_response '.')
    embeddings=$(join "$embeddings" "{\"text\": \"$val\"}")

    # echo $(flatten_embeddings_array $embeddings)
    echo $embeddings

    # Generate unique ID for this entry
    # id=$(uuidgen)
}

# Call the storage function
embeddings
