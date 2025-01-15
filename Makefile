# Directory path constants
PUBLIC_DIR = public
POSTS_DIR = src/posts
CSS_DIR = src/css
JS_DIR = src/js
IMAGES_DIR = src/images
SCRIPTS_DIR = src/scripts
TEMPLATES_DIR = src/templates

# Generated directory paths
PUBLIC_POSTS_DIR = $(PUBLIC_DIR)/posts
PUBLIC_CSS_DIR = $(PUBLIC_DIR)/css

# Template paths
POST_TEMPLATE = $(TEMPLATES_DIR)/post.html
HOME_TEMPLATE = $(TEMPLATES_DIR)/home.html

# File patterns
POST_FILES = $(POSTS_DIR)/*.md
PUBLIC_INDEX = $(PUBLIC_DIR)/index.html

# Server settings (localhost)
SERVER_PORT = 8080

# Script paths
BUILD_POSTS_SCRIPT = $(SCRIPTS_DIR)/build-posts.sh
BUILD_INDEX_SCRIPT = $(SCRIPTS_DIR)/build-index.sh
NEW_POST_SCRIPT = $(SCRIPTS_DIR)/new-post.sh
LIST_POSTS_SCRIPT = $(SCRIPTS_DIR)/list-posts.sh
RSS_SCRIPT = $(SCRIPTS_DIR)/generate-rss.sh
MINIFY_SCRIPT = $(SCRIPTS_DIR)/minify-assets.sh


# Ensure all scripts are executable
SCRIPTS = $(BUILD_POSTS_SCRIPT) $(BUILD_INDEX_SCRIPT) $(NEW_POST_SCRIPT) $(LIST_POSTS_SCRIPT) $(RSS_SCRIPT) $(MINIFY_SCRIPT)

.PHONY: default install-deps build clean setup posts index rss minify cleanup serve new-post list help

# Default target
default: install-deps build

# Install global dependencies
install-deps:
	@echo "🔧 Checking and installing global dependencies..."
	npm list -g uglify-js csso-cli html-minifier-terser || npm install -g uglify-js csso-cli html-minifier-terser

# Build the entire blog
build: clean setup posts index rss minify cleanup
	@echo "✨ Blog built successfully!"

# Clean the public directory
clean:
	@echo "🧹 Cleaning $(PUBLIC_DIR) directory..."
	rm -rf $(PUBLIC_DIR)

# Create necessary directories, copy static files, and ensure scripts are executable
setup:
	@echo "📁 Setting up directories..."
	mkdir -p $(PUBLIC_POSTS_DIR)
	cp -r $(CSS_DIR) $(PUBLIC_DIR)/
	cp -r $(JS_DIR) $(PUBLIC_DIR)/
	cp -r $(IMAGES_DIR) $(PUBLIC_DIR)/
	@echo "🔑 Making scripts executable..."
	@chmod +x $(SCRIPTS)

# Build all blog posts
posts: $(BUILD_POSTS_SCRIPT)
	@echo "📝 Building posts..."
	POST_FILES="$(POST_FILES)" \
	PUBLIC_POSTS_DIR="$(PUBLIC_POSTS_DIR)" \
	POST_TEMPLATE="$(POST_TEMPLATE)" \
	./$(BUILD_POSTS_SCRIPT)

# Build the index page
index: $(BUILD_INDEX_SCRIPT)
	@echo "🏠 Building index page..."
	POST_FILES="$(POST_FILES)" \
	PUBLIC_INDEX="$(PUBLIC_INDEX)" \
	HOME_TEMPLATE="$(HOME_TEMPLATE)" \
	./$(BUILD_INDEX_SCRIPT)

# Generate RSS feed
rss: $(RSS_SCRIPT)
	@echo "📰 Generating RSS feed..."
	./$(RSS_SCRIPT)

# Minify CSS, JS, and HTML files
minify: $(MINIFY_SCRIPT)
	@echo "🔧 Starting asset minification..."
	PUBLIC_DIR="$(PUBLIC_DIR)" \
	./$(MINIFY_SCRIPT)

# Cleanup unminified files
cleanup:
	@echo "🗑️ Cleaning up unminified files..."
	find $(PUBLIC_DIR)/css -type f -name "*.css" ! -name "*.min.css" -exec rm -f {} +
	find $(PUBLIC_DIR)/js -type f -name "*.js" ! -name "*.min.js" -exec rm -f {} +

# Serve the blog locally using Python's built-in server
serve: build
	@echo "🌎 Starting local server..."
	cd $(PUBLIC_DIR) && python3 -m http.server $(SERVER_PORT)

# Create a new blog post with today's date
new-post: $(NEW_POST_SCRIPT)
	@read -p "Enter post title: " title; \
	POSTS_DIR="$(POSTS_DIR)" \
	title="$$title" \
	./$(NEW_POST_SCRIPT)

# List all available posts
list: $(LIST_POSTS_SCRIPT)
	@echo "📚 Available posts..."
	POST_FILES="$(POST_FILES)" \
	./$(LIST_POSTS_SCRIPT)

# Show help
help:
	@echo "Available commands:"
	@echo " make build      - Build the entire blog"
	@echo " make clean      - Clean the $(PUBLIC_DIR) directory"
	@echo " make serve      - Build and serve the blog locally"
	@echo " make new-post   - Create a new blog post (will prompt for title)"
	@echo " make list       - List all available posts"