#!/usr/bin/env bash

# Gemini CLI Supercharger - Auto-Patching Wrapper
# This script ensures the optimization is always active, even after updates.

CACHE_FILE="$HOME/.gemini_supercharger_target"

if [ -f "$CACHE_FILE" ]; then
    TARGET_FILE=$(cat "$CACHE_FILE")
else
    GLOBAL_ROOT=$(npm root -g)
    TARGET_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/utils/shell-utils.js"
    echo "$TARGET_FILE" > "$CACHE_FILE"
fi

# 1. Quick Check: Is the optimization active?
if [ -f "$TARGET_FILE" ] && grep -q "executable: 'bash'" "$TARGET_FILE"; then
    echo "⚙️  Update detected! Re-applying Gemini Supercharger..."
    
    # Run the patch script silently
    "$(dirname "$0")/apply-patch.sh" > /dev/null 2>&1
fi

# 2. Execute the real Gemini with optimized options
export NODE_OPTIONS="--no-warnings=DEP0040"

# Use Bun if available for massive startup speedups, fallback to Node
if command -v bun > /dev/null 2>&1; then
    exec bun "$(which gemini)" "$@"
else
    exec gemini "$@"
fi
