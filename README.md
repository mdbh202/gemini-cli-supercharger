# Gemini CLI Supercharger 🚀

A high-performance optimization suite for the [Google Gemini CLI](https://github.com/google-gemini/gemini-cli) on macOS.

## 🌟 Infrastructure Optimization Findings

We have identified that the primary bottleneck in AI Agent performance is not the model speed, but the **Infrastructure Latency**. This repository provides a professional configuration to eliminate "Shell Bloat" and the "Startup Tax" associated with massive Node.js dependency trees.

### Performance Benchmarks (Mac M-Series)
| Metric | Original Build | Supercharged Build | Improvement |
|--------|----------------|--------------------|-------------|
| **Startup Time** | ~2.2 seconds | **~0.6 seconds** | **3.6x Faster** |
| **Search (Grep)** | ~2.5 seconds | **~0.1 seconds** | **25x Faster** |
| **Agent Turn-around** | ~5.0 seconds | **~1.2 seconds** | **4x Faster** |

---

## 🛠 Key Optimizations

### 1. Eliminating the "Startup Tax"
The standard Gemini CLI installation contains over **43,000 files** in its `node_modules`. Every time the agent "thinks," Node.js crawls this tree. We optimize this by using an automated wrapper that configures the V8 engine for maximum speed and suppresses non-critical warnings.

### 2. Zero Shell Bloat ("Set and Forget")
Standard builds often wrap tool calls in multiple layers of `bash -c`. We use a **Surgical Patch** that allows the AI to hit the OS kernel directly. 

**This optimization is self-healing.** Our wrapper script automatically detects if a Gemini CLI update has overwritten the patch and re-applies it in milliseconds.

---

## 🚀 Installation

### Step 1: Clone the Repository
```bash
git clone https://github.com/mdbh202/gemini-cli-supercharger.git ~/gemini-cli-supercharger
```

### Step 2: Add the Turbo Alias
Add the following to your `~/.zshrc` or `~/.bashrc`:
```bash
alias gemini='~/gemini-cli-supercharger/scripts/gemini-wrapper.sh'
```

### Step 3: Refresh Terminal
```bash
source ~/.zshrc
```

---

## 🧪 Testing & Verification

We provide a suite of tools to verify your performance gains and ensure the optimizations are healthy:

### 1. Integrity Test
Verify that all patches (Kernel injection, Path cache, V8 tuning) are correctly applied:
```bash
bash ~/gemini-cli-supercharger/scripts/test-integrity.sh
```

### 2. Performance Benchmark
Compare your Standard build against the Supercharged build across multiple iterations:
```bash
bash ~/gemini-cli-supercharger/scripts/benchmark.sh
```

---

## 🔙 Revert to Normal (Uninstall)

If you ever experience issues or simply want to return to the factory-default Gemini CLI, it's very easy to revert everything:

### Step 1: Run the Uninstall Script
Run the provided uninstallation script to safely restore your global `node_modules` from the backup and clear the path cache:
```bash
bash ~/gemini-cli-supercharger/scripts/uninstall.sh
```

### Step 2: Remove the Alias
Open your `~/.zshrc` (or `~/.bashrc`) file and delete the line you added during installation:
```bash
# Delete this line:
alias gemini='~/gemini-cli-supercharger/scripts/gemini-wrapper.sh'
```

### Step 3: Refresh Terminal
```bash
source ~/.zshrc
```
Your Gemini CLI will now run exactly as it did before.

---

## ⚠️ Disclaimer & Risks

While these optimizations provide a significant performance boost, users should be aware of the following technical considerations:

1.  **Shell Compatibility:** The patch switches the internal command executor from `/bin/bash` to `/bin/zsh`. While Zsh is the default on modern macOS, certain legacy environment-dependent hooks may behave differently.
2.  **Experimental Status:** These optimizations are community-developed and are not officially supported by Google. Use at your own risk.

---

## 📄 License
Apache-2.0
