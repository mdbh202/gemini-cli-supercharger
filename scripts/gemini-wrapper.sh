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

# 3. Level 4: Background WASM Pre-fetch
# Overlaps binary I/O with Node.js startup for ~200ms gain.
# We import directly from the already-resolved TARGET_FILE.
node --no-warnings -e "import('$TARGET_FILE').then(m => m.initializeShellParsers())" > /dev/null 2>&1 &

# 4. Stealth Boot Mode: Suppress telemetry and SDK overhead
export OTEL_SDK_DISABLED=true
export GEMINI_TELEMETRY_DISABLED=true

# 5. Atomic Initialization: Fix O(n^2) extension loading bottleneck
export GEMINI_CLI_BATCH_LOAD=1

# 6. Execute the real Gemini with optimized options
# --max-old-space-size prevents Garbage Collection thrashing during heavy agent processing
export NODE_OPTIONS="--no-warnings=DEP0040 --max-old-space-size=8192"

# 7. Level 3 Handoff Loop: Catch RELAUNCH_EXIT_CODE=199
RELAUNCH_EXIT_CODE=199
EXIT_CODE=$RELAUNCH_EXIT_CODE
while [ $EXIT_CODE -eq $RELAUNCH_EXIT_CODE ]; do
    # Call the real gemini
    # IMPORTANT: Do NOT use exec inside the loop, as exec replaces the shell process and breaks the loop.
    gemini "$@"
    EXIT_CODE=$?
    
    # After the first successful run, clear the batch load flag
    # so that any dynamic reloads inside the session behave normally.
    unset GEMINI_CLI_BATCH_LOAD
done
