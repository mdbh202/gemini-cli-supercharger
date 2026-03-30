#!/usr/bin/env bash

# Gemini CLI Supercharger - Integrity Test Suite
# Verifies that all optimizations are correctly applied and active.

echo "🔍 Running Supercharger Integrity Check..."
echo ""

# 1. Check Path Cache
CACHE_FILE="$HOME/.gemini_supercharger_target"
if [ -f "$CACHE_FILE" ]; then
    echo "✅ [SUCCESS] Path cache file found: $CACHE_FILE"
    TARGET_FILE=$(cat "$CACHE_FILE")
else
    echo "❌ [FAILURE] Path cache file missing. (Run gemini once to generate it)"
fi

# 2. Check Shell Injection
if [ -f "$TARGET_FILE" ]; then
    if grep -q "executable: 'zsh'" "$TARGET_FILE"; then
        echo "✅ [SUCCESS] Kernel injection verified: shell-utils.js is using Zsh."
    else
        echo "❌ [FAILURE] Kernel injection missing: shell-utils.js is still using Bash."
    fi
else
    echo "⚠️  [SKIPPED] Cannot verify kernel injection (Target file not found)."
fi

# 4. Check V8 Optimizations
WRAPPER_PATH="$(dirname "$0")/gemini-wrapper.sh"
if grep -q "max-old-space-size=8192" "$WRAPPER_PATH"; then
    echo "✅ [SUCCESS] V8 Optimization verified: Memory limit set to 8GB."
else
    echo "❌ [FAILURE] V8 Optimization missing in wrapper script."
fi

# 5. Check Level 4 Optimizations
if grep -q "GEMINI_CLI_BATCH_LOAD=1" "$WRAPPER_PATH"; then
    echo "✅ [SUCCESS] Level 4: Atomic Batch Load flag found in wrapper."
else
    echo "❌ [FAILURE] Level 4: Atomic Batch Load flag missing in wrapper."
fi

if grep -q "initializeShellParsers" "$WRAPPER_PATH"; then
    echo "✅ [SUCCESS] Level 4: Background WASM pre-fetch found in wrapper."
else
    echo "❌ [FAILURE] Level 4: Background WASM pre-fetch missing in wrapper."
fi

GLOBAL_ROOT=$(npm root -g)
LOADER_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/utils/extensionLoader.js"
if [ -f "$LOADER_FILE" ] && grep -q "GEMINI_CLI_BATCH_LOAD" "$LOADER_FILE"; then
    echo "✅ [SUCCESS] Level 4: Atomic Initialization verified in core."
else
    echo "❌ [FAILURE] Level 4: Atomic Initialization missing in core."
fi

# 6. Check Wrapper Health
if [ -x "$WRAPPER_PATH" ]; then
    echo "✅ [SUCCESS] Wrapper script is executable."
else
    echo "❌ [FAILURE] Wrapper script is NOT executable."
fi

# 5. Check Level 3: Relaunch Bypass
GLOBAL_ROOT=$(npm root -g)
RELAUNCH_FILE="$GLOBAL_ROOT/@google/gemini-cli/dist/src/utils/relaunch.js"
if [ -f "$RELAUNCH_FILE" ]; then
    if grep -q "if (true || process.env\['GEMINI_CLI_NO_RELAUNCH'\])" "$RELAUNCH_FILE"; then
        echo "✅ [SUCCESS] Level 3: Relaunch bypass verified."
    else
        echo "❌ [FAILURE] Level 3: Relaunch bypass missing in relaunch.js."
    fi
fi

# 6. Check Level 3: Project ID Cache
STORAGE_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/config/storage.js"
if [ -f "$STORAGE_FILE" ]; then
    if grep -q "project_id" "$STORAGE_FILE"; then
        echo "✅ [SUCCESS] Level 3: Project ID cache verified."
    else
        echo "❌ [FAILURE] Level 3: Project ID cache missing in storage.js."
    fi
fi

echo ""
echo "🏁 Integrity check complete!"
