#!/usr/bin/env bash

# Gemini CLI Supercharger - Auto-Patching Wrapper
# This script ensures the optimization is always active, even after updates.

# 1. Zero-Latency Path Resolution
# Avoids the ~400ms penalty of running 'npm root -g' on every command
CACHE_FILE="$HOME/.gemini_supercharger_target"

if [ -f "$CACHE_FILE" ]; then
    TARGET_FILE=$(cat "$CACHE_FILE")
else
    GLOBAL_ROOT=$(npm root -g)
    TARGET_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/utils/shell-utils.js"
    echo "$TARGET_FILE" > "$CACHE_FILE"
fi

# 2. Quick Check: Is the optimization active?
# We check if the file still contains 'bash' as the executable
if [ -f "$TARGET_FILE" ] && grep -q "executable: 'bash'" "$TARGET_FILE"; then
    echo "⚙️  Update detected! Re-applying Gemini Supercharger..."
    
    # Run the patch script silently
    "$(dirname "$0")/apply-patch.sh" > /dev/null 2>&1
fi

# 3. Execute the real Gemini with optimized options
# --max-old-space-size prevents Garbage Collection thrashing during heavy agent processing
export NODE_OPTIONS="--no-warnings=DEP0040 --max-old-space-size=8192"
exec gemini "$@"
