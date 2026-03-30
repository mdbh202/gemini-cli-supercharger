#!/usr/bin/env bash

# Gemini CLI Supercharger - Uninstall Script
# Safely reverts all patches and restores the factory state.

echo "Locating Gemini CLI installation..."

CACHE_FILE="$HOME/.gemini_supercharger_target"
GLOBAL_ROOT=$(npm root -g)

if [ -f "$CACHE_FILE" ]; then
    TARGET_FILE=$(cat "$CACHE_FILE")
else
    TARGET_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/utils/shell-utils.js"
fi

if [ -f "${TARGET_FILE}.bak" ]; then
    echo "Restoring original shell-utils.js from backup..."
    cp "${TARGET_FILE}.bak" "$TARGET_FILE"
    echo "Original shell-utils.js restored."
else
    echo "Warning: No backup file found for shell-utils.js."
fi

# Revert relaunch.js
RELAUNCH_FILE="$GLOBAL_ROOT/@google/gemini-cli/dist/src/utils/relaunch.js"
if [ -f "${RELAUNCH_FILE}.bak" ]; then
    echo "Restoring original relaunch.js from backup..."
    cp "${RELAUNCH_FILE}.bak" "$RELAUNCH_FILE"
    echo "Original relaunch.js restored."
fi

# Revert storage.js
STORAGE_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/config/storage.js"
if [ -f "${STORAGE_FILE}.bak" ]; then
    echo "Restoring original storage.js from backup..."
    cp "${STORAGE_FILE}.bak" "$STORAGE_FILE"
    echo "Original storage.js restored."
fi

# Revert extensionLoader.js
LOADER_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/utils/extensionLoader.js"
if [ -f "${LOADER_FILE}.bak" ]; then
    echo "Restoring original extensionLoader.js from backup..."
    cp "${LOADER_FILE}.bak" "$LOADER_FILE"
    echo "Original extensionLoader.js restored."
fi

echo "All original files restored successfully."

# Clean up the cache file
if [ -f "$CACHE_FILE" ]; then
    rm "$CACHE_FILE"
    echo "Removed path cache file."
fi

echo ""
echo "Uninstallation complete."
echo "IMPORTANT: You must manually remove the 'gemini' alias from your ~/.zshrc or ~/.bashrc file."
echo "   Look for the line: alias gemini='.../gemini-wrapper.sh'"
echo "   After removing it, run 'source ~/.zshrc' to refresh your terminal."
