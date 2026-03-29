#!/usr/bin/env bash

# Gemini CLI Supercharger - Auto-Patching Wrapper
# This script ensures the optimization is always active, even after updates.

GLOBAL_ROOT=$(npm root -g)
TARGET_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/utils/shell-utils.js"

# 1. Quick Check: Is the optimization active?
# We check if the file still contains 'bash' as the executable
if [ -f "$TARGET_FILE" ] && grep -q "executable: 'bash'" "$TARGET_FILE"; then
    echo "⚙️  Update detected! Re-applying Gemini Supercharger..."
    
    # Run the patch script silently
    "$(dirname "$0")/apply-patch.sh" > /dev/null 2>&1
fi

# 2. Execute the real Gemini with optimized options
export NODE_OPTIONS="--no-warnings=DEP0040"
exec gemini "$@"
