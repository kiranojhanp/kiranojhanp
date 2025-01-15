#!/bin/bash

# Required variables passed from justfile:
# POSTS_DIR - Directory containing posts
# title - Post title passed as argument

if [ -z "$title" ]; then
    echo "Error: Post title is required"
    exit 1
fi

echo "📝 Creating new post: $title"
slug=$(echo "$title" | tr '[:upper:] ' '[:lower:]-' | sed 's/[^a-z0-9-]//g')
date=$(date +%Y-%m-%d)
post_file="$POSTS_DIR/$date-$slug.md"

echo "---" > "$post_file"
echo "title: $title" >> "$post_file"
echo "date: $date" >> "$post_file"
echo "---" >> "$post_file"
echo -e "\nWrite your post here..." >> "$post_file"
echo "Created $post_file"