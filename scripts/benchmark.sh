#!/usr/bin/env bash

# Gemini CLI Supercharger - Benchmarking Tool
# Provides a fair, multi-iteration comparison between Standard and Supercharged builds.

# 1. Path Resolution
SUPERCHARGED_WRAPPER="$(dirname "$0")/gemini-wrapper.sh"
NORMAL_BUILD="/opt/homebrew/bin/gemini"

if [ ! -f "$NORMAL_BUILD" ]; then
    # Fallback to the default system binary
    NORMAL_BUILD=$(which gemini)
fi

echo "Starting Gemini Supercharger Benchmark..."
echo "Standard:     $NORMAL_BUILD"
echo "Supercharged: $SUPERCHARGED_WRAPPER"
echo ""

# Function to run multi-iteration benchmark
run_bench() {
    local LABEL=$1
    local CMD=$2
    local ITERATIONS=3
    
    echo "=== $LABEL ==="
    
    # Warm up run
    echo "Warming up..."
    "$CMD" --version > /dev/null 2>&1
    
    echo "Running $ITERATIONS iterations for Startup Time (--version)..."
    for i in $(seq 1 $ITERATIONS); do
        echo -n "  Run $i: "
        # Use TIMEFORMAT to get only the real time in seconds
        ( export TIMEFORMAT='%R'; time "$CMD" --version > /dev/null 2>&1 ) 2>&1
    done
    
    echo ""
    echo "Running $ITERATIONS iterations for Extension Loading (--list-extensions)..."
    for i in $(seq 1 $ITERATIONS); do
        echo -n "  Run $i: "
        # --list-extensions tests the full boot cycle + extension loading without agent loops
        ( export TIMEFORMAT='%R'; time "$CMD" --list-extensions > /dev/null 2>&1 ) 2>&1
    done
    echo ""
}

# 1. Test Standard Build
run_bench "Standard Build" "$NORMAL_BUILD"

# 2. Test Supercharged Build
run_bench "Supercharged Build" "$SUPERCHARGED_WRAPPER"

echo "Benchmark complete."
echo "Tip: Compare the 'real' time across runs. Smaller is better."
echo "Supercharged should consistently show 30-50% improvement in startup."
