#!/usr/bin/env bash

# Gemini CLI Supercharger - Uninstall Script
# Safely reverts all patches and restores the factory state.

echo "🔍 Locating Gemini CLI installation..."

CACHE_FILE="$HOME/.gemini_supercharger_target"

if [ -f "$CACHE_FILE" ]; then
    TARGET_FILE=$(cat "$CACHE_FILE")
else
    GLOBAL_ROOT=$(npm root -g)
    TARGET_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/utils/shell-utils.js"
fi

if [ -f "${TARGET_FILE}.bak" ]; then
    echo "🔄 Restoring original shell-utils.js from backup..."
    cp "${TARGET_FILE}.bak" "$TARGET_FILE"
    echo "✅ Original files restored successfully."
else
    echo "⚠️ No backup file found. It may have already been restored or the CLI was reinstalled."
    # Attempt an in-place revert of the specific zsh patch just in case
    if [ -f "$TARGET_FILE" ]; then
         sed -i '' "s/executable: 'zsh', argsPrefix: \['-c'\], shell: 'zsh'/executable: 'bash', argsPrefix: \['-c'\], shell: 'bash'/g" "$TARGET_FILE"
         echo "✅ In-place revert applied to shell-utils.js."
    fi
fi

# Clean up the cache file
if [ -f "$CACHE_FILE" ]; then
    rm "$CACHE_FILE"
    echo "🧹 Removed path cache file."
fi

echo ""
echo "🎉 Uninstallation complete!"
echo "⚠️ IMPORTANT: You must manually remove the 'gemini' alias from your ~/.zshrc or ~/.bashrc file."
echo "   Look for the line: alias gemini='.../gemini-wrapper.sh'"
echo "   After removing it, run 'source ~/.zshrc' to refresh your terminal."
