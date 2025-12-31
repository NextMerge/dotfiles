#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Become Personal
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪟

# Documentation:
# @raycast.author NextMerge
# @raycast.authorURL https://raycast.com/NextMerge

open "raycast://customWindowManagementCommand?&name=Layout%20-%20Browse"
sleep 0.5

open "raycast://customWindowManagementCommand?&name=Layout%20-%20Code"
sleep 0.5

open "raycast://customWindowManagementCommand?&name=Layout%20-%20Media"
sleep 0.5

open "raycast://customWindowManagementCommand?&name=Layout%20-%20Writing"

echo "Personal Layouts applied"

