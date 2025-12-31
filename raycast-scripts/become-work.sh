#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Become Work
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪟

# Documentation:
# @raycast.author NextMerge
# @raycast.authorURL https://raycast.com/NextMerge

# Run apply-layouts script command
open "raycast://script-commands/become-personal"

# Small delay to ensure first command processes
sleep 0.5

# Apply Work layout
open "raycast://customWindowManagementCommand?&name=Layout%20-%20Work"

echo "Work layouts applied"

