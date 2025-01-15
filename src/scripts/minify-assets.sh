#!/bin/bash

# Required variables passed from Makefile:
# PUBLIC_DIR - Public directory containing assets to minify

# Function to minify CSS files
minify_css() {
    echo "🔧 Minifying CSS..."
    local css_dir="$PUBLIC_DIR/css"
    find "$css_dir" -type f -name "*.css" ! -name "*.min.css" | while read -r file; do
        output_file="${file%.css}.min.css"
        echo "Processing: $file -> $output_file"
        csso "$file" --output "$output_file"
    done
}

# Function to minify JavaScript files
minify_js() {
    echo "🔧 Minifying JavaScript..."
    local js_dir="$PUBLIC_DIR/js"
    find "$js_dir" -type f -name "*.js" ! -name "*.min.js" | while read -r file; do
        output_file="${file%.js}.min.js"
        echo "Processing: $file -> $output_file"
        uglifyjs "$file" --compress --mangle -o "$output_file"
    done
}

# Function to minify HTML files
minify_html() {
    echo "🔧 Minifying HTML..."
    
    # Minify index.html
    if [ -f "$PUBLIC_DIR/index.html" ]; then
        echo "Processing: index.html"
        html-minifier-terser \
            --collapse-whitespace \
            --remove-comments \
            --minify-css true \
            --minify-js true \
            "$PUBLIC_DIR/index.html" \
            -o "$PUBLIC_DIR/index.html.tmp" \
        && mv "$PUBLIC_DIR/index.html.tmp" "$PUBLIC_DIR/index.html"
    fi

    # Minify post HTML files
    find "$PUBLIC_DIR/posts" -type f -name "index.html" | while read -r file; do
        echo "Processing: $file"
        html-minifier-terser \
            --collapse-whitespace \
            --remove-comments \
            --minify-css true \
            --minify-js true \
            "$file" \
            -o "$file.tmp" \
        && mv "$file.tmp" "$file"
    done
}

# Main execution
echo "🔧 Starting asset minification..."

# Check if required tools are available
if ! command -v csso >/dev/null; then
    echo "Error: csso-cli is not installed. Please run 'make install-deps' first."
    exit 1
fi

if ! command -v uglifyjs >/dev/null; then
    echo "Error: uglify-js is not installed. Please run 'make install-deps' first."
    exit 1
fi

if ! command -v html-minifier-terser >/dev/null; then
    echo "Error: html-minifier-terser is not installed. Please run 'make install-deps' first."
    exit 1
fi

# Run minification processes
minify_css
minify_js
minify_html

echo "✨ Asset minification complete!"