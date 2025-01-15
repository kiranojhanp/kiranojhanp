#!/bin/bash

# Required variables passed from justfile:
# POST_FILES - Pattern for markdown posts

echo "📚 Available posts:"
for post in $POST_FILES; do
    if [ -e "$post" ]; then
        date=$(grep -m 1 "date:" "$post" | cut -d' ' -f2)
        title=$(grep -m 1 "title:" "$post" | cut -d':' -f2- | sed 's/^[ ]*//')
        echo " $date - $title"
    fi
done