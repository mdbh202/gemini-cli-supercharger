#!/usr/bin/env bash

# Gemini CLI Supercharger - Universal Mac Patch Script
# This version works for NVM, Homebrew, and Standard Node installs.

echo "Locating Gemini CLI installation..."

# Use npm to find the global root instead of guessing paths
CACHE_FILE="$HOME/.gemini_supercharger_target"
GLOBAL_ROOT=$(npm root -g)

if [ -f "$CACHE_FILE" ]; then
    TARGET_FILE=$(cat "$CACHE_FILE")
else
    TARGET_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/utils/shell-utils.js"
    echo "$TARGET_FILE" > "$CACHE_FILE"
fi

if [ ! -f "$TARGET_FILE" ]; then
    # Fallback search if npm root doesn't find it directly (some setups)
    TARGET_FILE=$(find "$GLOBAL_ROOT" -name "shell-utils.js" | grep "@google/gemini-cli-core" | head -n 1)
fi

if [ -z "$TARGET_FILE" ] || [ ! -f "$TARGET_FILE" ]; then
    echo "Error: Could not find Gemini CLI core files."
    echo "Make sure you have installed it globally: npm install -g @google/gemini-cli"
    exit 1
fi

echo "Found target: $TARGET_FILE"

# Create a backup if one doesn't exist
if [ ! -f "${TARGET_FILE}.bak" ]; then
    cp "$TARGET_FILE" "${TARGET_FILE}.bak"
    echo "Created backup of original shell-utils.js"
fi

# Apply the zsh optimization
# macOS ships with a very old version of Bash (3.2). 
# Switching to the native Zsh provides better performance and path handling.
sed -i '' "s/executable: 'bash', argsPrefix: \['-c'\], shell: 'bash'/executable: 'zsh', argsPrefix: \['-c'\], shell: 'bash'/g" "$TARGET_FILE"

echo "Optimization applied successfully."

# Level 3: Relaunch Bypass
RELAUNCH_FILE="$GLOBAL_ROOT/@google/gemini-cli/dist/src/utils/relaunch.js"
if [ -f "$RELAUNCH_FILE" ]; then
    if [ ! -f "${RELAUNCH_FILE}.bak" ]; then
        cp "$RELAUNCH_FILE" "${RELAUNCH_FILE}.bak"
        echo "Created backup of relaunch.js"
    fi
    # Patch relaunchAppInChildProcess to always return early
    if ! grep -q "true ||" "$RELAUNCH_FILE"; then
        sed -i '' "s/if (process.env\['GEMINI_CLI_NO_RELAUNCH'\]) {/if (true || process.env['GEMINI_CLI_NO_RELAUNCH']) {/g" "$RELAUNCH_FILE"
        echo "Level 3: Relaunch bypass applied."
    fi
fi

# Level 3: Project ID Cache
STORAGE_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/config/storage.js"
if [ -f "$STORAGE_FILE" ]; then
    if [ ! -f "${STORAGE_FILE}.bak" ]; then
        cp "$STORAGE_FILE" "${STORAGE_FILE}.bak"
        echo "Created backup of storage.js"
    fi
    
    if ! grep -q "projectIdPath" "$STORAGE_FILE"; then
        # Insert Project ID Cache read logic
        # We use perl for reliable multi-line replacement on macOS
        perl -i -0777 -pe 's/if \(this\.projectIdentifier\) \{\s+return;\s+\}/if (this.projectIdentifier) {\n                return;\n            }\n            const projectIdPath = path.join(this.targetDir, GEMINI_DIR, "project_id");\n            if (fs.existsSync(projectIdPath)) {\n                this.projectIdentifier = fs.readFileSync(projectIdPath, "utf8").trim();\n                return;\n            }/' "$STORAGE_FILE"
        
        # Insert Project ID Cache write logic
        perl -i -pe 's/this\.projectIdentifier = await registry\.getShortId\(this\.getProjectRoot\(\)\);/this.projectIdentifier = await registry.getShortId(this.getProjectRoot()); try { fs.mkdirSync(path.dirname(projectIdPath), { recursive: true }); fs.writeFileSync(projectIdPath, this.projectIdentifier); } catch (e) {}/g' "$STORAGE_FILE"
        
        echo "Level 3: Project ID cache applied."
    fi
fi

# Level 4: Atomic Initialization
LOADER_FILE="$GLOBAL_ROOT/@google/gemini-cli/node_modules/@google/gemini-cli-core/dist/src/utils/extensionLoader.js"
if [ -f "$LOADER_FILE" ]; then
    if [ ! -f "${LOADER_FILE}.bak" ]; then
        cp "$LOADER_FILE" "${LOADER_FILE}.bak"
        echo "Created backup of extensionLoader.js"
    fi
    
    # Inhibit redundant reloads during batch load
    if ! grep -q "GEMINI_CLI_BATCH_LOAD" "$LOADER_FILE"; then
        sed -i '' "s/if (this.isStarting) {/if (this.isStarting || process.env.GEMINI_CLI_BATCH_LOAD) {/g" "$LOADER_FILE"
        echo "Level 4: Atomic Initialization applied."
    fi
fi

echo "Please restart your terminal or run 'source ~/.zshrc'."
