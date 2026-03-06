---
name: superpowers-finishing
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the superpowers-finishing skill to complete this work."

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
# npm test / cargo test / pytest / go test ./...
```

**If tests fail:** Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Determine Base Branch

Identify the base branch (e.g., main, master).

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 4: Execute Choice

#### Option 1: Merge Locally
- Switch to base branch
- Pull latest
- Merge feature branch
- Verify tests on merged result
- If tests pass, delete feature branch (if applicable)

#### Option 2: Push and Create PR
- Push branch
- Create PR with summary and test plan

#### Option 3: Keep As-Is
- Report: "Keeping branch <name>."

#### Option 4: Discard
- **Confirm first:** "Type 'discard' to confirm."
- If confirmed, delete branch/work.

### Step 5: Cleanup
- Cleanup any temporary files or worktrees if used.

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4