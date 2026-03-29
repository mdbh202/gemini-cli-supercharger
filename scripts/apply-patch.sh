#!/usr/bin/env bash

# Gemini CLI Supercharger - Surgical Patch Script
# This script optimizes the shell execution path in gemini-cli-core

TARGET_FILE=$(find ~/.nvm/versions/node -name "shell-utils.js" | grep "@google/gemini-cli-core" | head -n 1)

if [ -z "$TARGET_FILE" ]; then
    echo "❌ Could not find shell-utils.js in your NVM node_modules."
    exit 1
fi

echo "🚀 Found target: $TARGET_FILE"

# Backup original
cp "$TARGET_FILE" "${TARGET_FILE}.bak"

# Apply optimization (Using zsh for startup speed)
sed -i '' "s/executable: 'bash', argsPrefix: \['-c'\], shell: 'bash'/executable: 'zsh', argsPrefix: \['-c'\], shell: 'bash'/g" "$TARGET_FILE"

echo "✅ Optimization applied successfully!"
echo "🔄 Please restart your terminal or run 'source ~/.zshrc'."
