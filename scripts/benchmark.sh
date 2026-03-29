#!/usr/bin/env bash

# Gemini CLI Supercharger - Benchmarking Tool
# Measures startup and search performance.

echo "⏱️  Starting Gemini Supercharger Benchmark..."

# 1. Measure Startup
echo "--- Startup Speed ---"
time gemini --version

# 2. Measure Search (Grep)
echo ""
echo "--- Search Speed (Mock Task) ---"
time gemini -p "grep search for 'main' in current directory" > /dev/null

echo ""
echo "✅ Benchmark complete. Compare these results to your original Gemini speeds!"
