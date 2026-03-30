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

# 3. Check V8 Optimizations
WRAPPER_PATH="$(dirname "$0")/gemini-wrapper.sh"
if grep -q "max-old-space-size=8192" "$WRAPPER_PATH"; then
    echo "✅ [SUCCESS] V8 Optimization verified: Memory limit set to 8GB."
else
    echo "❌ [FAILURE] V8 Optimization missing in wrapper script."
fi

# 4. Check Wrapper Health
if [ -x "$WRAPPER_PATH" ]; then
    echo "✅ [SUCCESS] Wrapper script is executable."
else
    echo "❌ [FAILURE] Wrapper script is NOT executable."
fi

echo ""
echo "🏁 Integrity check complete!"
