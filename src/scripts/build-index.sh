#!/bin/bash

# Required variables passed from justfile:
# POST_FILES - Pattern for markdown posts
# PUBLIC_INDEX - Output path for index.html
# HOME_TEMPLATE - Template file path

echo "🏠 Building index page..."
{
    echo "---"
    echo "year: $(date +%Y)"
    echo "posts:"
    
    # Collect posts with metadata into a temporary file for sorting
    temp_file=$(mktemp)
    for post in $POST_FILES; do
        if [ -e "$post" ]; then
            title_slug=$(basename "$post" .md | sed 's/^[0-9\-]*//')
            date=$(grep -m 1 "date:" "$post" | cut -d' ' -f2)
            title=$(grep -m 1 "title:" "$post" | cut -d':' -f2- | sed 's/^[ ]*//')
            echo "$date|$title|posts/$title_slug" >> "$temp_file"
        fi
    done

    # Sort posts by date in descending order and format them for output
    sort -r "$temp_file" | while IFS='|' read -r date title url; do
        echo "  - date: \"$date\""
        echo "    title: \"$title\""
        echo "    url: \"$url\""
    done

    # Clean up
    rm "$temp_file"

    echo "---"
} > temp_home.md

echo " Generated temporary index content:"
cat temp_home.md

pandoc temp_home.md \
    --template=$HOME_TEMPLATE \
    -o $PUBLIC_INDEX
rm temp_home.md