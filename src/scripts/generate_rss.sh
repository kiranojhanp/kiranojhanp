#!/usr/bin/env bash

# Configuration
POSTS_DIR="src/posts"
RSS_TEMPLATE="src/templates/rss.xml"
OUTPUT_FILE="public/rss.xml"
BLOG_URL="http://kojha.com.np"
BLOG_TITLE="Kiran"
BLOG_DESCRIPTION="A place to share my thoughts"

# Function to extract metadata from markdown file
extract_metadata() {
    local file="$1"
    local field="$2"
    grep -m 1 "^$field:" "$file" | cut -d':' -f2- | sed 's/^[ ]*//'
}

# Function to extract content from markdown file (everything after the frontmatter)
extract_content() {
    local file="$1"
    # Skip YAML frontmatter and get the content
    sed -n '/^---$/,/^---$/!p' "$file" | sed '1,/^---$/d' | head -n 300
}

# Function to format date for RSS (macOS compatible)
format_rss_date() {
    local input_date="$1"  # Expected format: YYYY-MM-DD
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version
        local year="${input_date%%-*}"
        local month="${input_date#*-}"; month="${month%%-*}"
        local day="${input_date##*-}"
        
        # Convert month number to timestamp for date command
        local timestamp=$(date -j -f "%Y-%m-%d" "$input_date" "+%s" 2>/dev/null)
        if [ $? -eq 0 ]; then
            date -j -f "%s" "$timestamp" "+%a, %d %b %Y %H:%M:%S %z"
        else
            # Fallback if date conversion fails
            echo "$input_date 00:00:00 +0000"
        fi
    else
        # Linux version
        date -d "$input_date" "+%a, %d %b %Y %H:%M:%S %z"
    fi
}

# Function to generate a single RSS item
generate_rss_item() {
    local file="$1"
    local title=$(extract_metadata "$file" "title")
    local date=$(extract_metadata "$file" "date")
    local rss_date=$(format_rss_date "$date")
    local slug=$(basename "$file" .md | sed 's/^[0-9\-]*//')
    local url="${BLOG_URL}/posts/${slug}.html"
    local content=$(extract_content "$file" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

    cat <<EOF
 <item>
  <title>$title</title>
  <link>$url</link>
  <guid>$url</guid>
  <pubDate>$rss_date</pubDate>
  <description><![CDATA[$content]]></description>
 </item>
EOF
}

# Main script
main() {
    # Create output directory if it doesn't exist
    mkdir -p "$(dirname "$OUTPUT_FILE")"

    # Generate current build date (macOS compatible)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        current_date=$(date "+%a, %d %b %Y %H:%M:%S %z")
    else
        current_date=$(date "+%a, %d %b %Y %H:%M:%S %z")
    fi

    # Generate all RSS items
    items=""
    while IFS= read -r -d '' file; do
        items="${items}$(generate_rss_item "$file")"$'\n'
    done < <(find "$POSTS_DIR" -name "*.md" -type f -print0 | sort -rz)

    # Read the template
    template=$(cat "$RSS_TEMPLATE")

    # Replace placeholders
    output="${template/\{\{lastBuildDate\}\}/$current_date}"
    output="${output/\{\{items\}\}/$items}"

    # Write the output
    echo "$output" > "$OUTPUT_FILE"
    echo "RSS feed generated at $OUTPUT_FILE"
}

# Run the script if not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi