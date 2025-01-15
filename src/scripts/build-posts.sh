#!/bin/bash

# Required variables passed from justfile:
# POST_FILES - Pattern for markdown posts
# PUBLIC_POSTS_DIR - Output directory for posts
# POST_TEMPLATE - Template file path

echo "📝 Building posts..."
for post in $POST_FILES; do
    if [ -e "$post" ]; then
        infile=$(basename "$post")
        title_slug=$(basename "$post" .md | sed 's/^[0-9\-]*//')
        outfolder="$title_slug"
        mkdir "$PUBLIC_POSTS_DIR/$outfolder"
        echo " Building $infile -> $outfolder/index.html"
        pandoc "$post" \
            --template=$POST_TEMPLATE \
            --variable year="$(date +%Y)" \
            -o "$PUBLIC_POSTS_DIR/$outfolder/index.html"
    fi
done