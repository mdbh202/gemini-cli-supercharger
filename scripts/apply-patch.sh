#!/usr/bin/env bash

# Gemini CLI Supercharger - Universal Mac Patch Script
# This version works for NVM, Homebrew, and Standard Node installs.

echo "🔍 Locating Gemini CLI installation..."

# Use npm to find the global root instead of guessing paths
CACHE_FILE="$HOME/.gemini_supercharger_target"

if [ -f "$CACHE_FILE" ]; then
    TARGET_FILE=$(cat "$CACHE_FILE")
else
    GLOBAL_ROOT=$(npm root -g)
    TARGET_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/utils/shell-utils.js"
    echo "$TARGET_FILE" > "$CACHE_FILE"
fi

if [ ! -f "$TARGET_FILE" ]; then
    # Fallback search if npm root doesn't find it directly (some setups)
    TARGET_FILE=$(find "$GLOBAL_ROOT" -name "shell-utils.js" | grep "@google/gemini-cli-core" | head -n 1)
fi

if [ -z "$TARGET_FILE" ] || [ ! -f "$TARGET_FILE" ]; then
    echo "❌ Could not find Gemini CLI core files."
    echo "Make sure you have installed it globally: npm install -g @google/gemini-cli"
    exit 1
fi

echo "🚀 Found target: $TARGET_FILE"

# Create a backup if one doesn't exist
if [ ! -f "${TARGET_FILE}.bak" ]; then
    cp "$TARGET_FILE" "${TARGET_FILE}.bak"
    echo "💾 Created backup of original shell-utils.js"
fi

# Apply the zsh optimization
# macOS ships with a very old version of Bash (3.2). 
# Switching to the native Zsh provides better performance and path handling.
sed -i '' "s/executable: 'bash', argsPrefix: \['-c'\], shell: 'bash'/executable: 'zsh', argsPrefix: \['-c'\], shell: 'zsh'/g" "$TARGET_FILE"

# Apply Bun compatibility patches (remove ?binary from wasm imports)
# This enables the much faster 'bun' runtime to execute the CLI natively.
sed -i '' "s/'web-tree-sitter\/tree-sitter.wasm?binary'/'web-tree-sitter\/tree-sitter.wasm'/g" "$TARGET_FILE"
sed -i '' "s/'tree-sitter-bash\/tree-sitter-bash.wasm?binary'/'tree-sitter-bash\/tree-sitter-bash.wasm'/g" "$TARGET_FILE"

echo "✅ Optimization applied successfully!"
echo "🔄 Please restart your terminal or run 'source ~/.zshrc'."
