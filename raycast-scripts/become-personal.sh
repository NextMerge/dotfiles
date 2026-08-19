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

open "raycast://extensions/raycast/window-management/layout-browse"
sleep 0.5

open "raycast://extensions/raycast/window-management/layout-code"
sleep 0.5

open "raycast://extensions/raycast/window-management/layout-media"
sleep 0.5

open "raycast://extensions/raycast/window-management/layout-writing"

echo "Personal Layouts applied"

