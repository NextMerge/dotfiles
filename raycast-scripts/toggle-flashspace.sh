#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle FlashSpace
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️

# Documentation:
# @raycast.author NextMerge
# @raycast.authorURL https://raycast.com/NextMerge

# Check if FlashSpace is running
if pgrep -x "FlashSpace" > /dev/null; then
    # FlashSpace is running, turn it off
    osascript -e 'quit app "FlashSpace"'
    defaults write com.apple.WindowManager GloballyEnabled -bool true
    osascript -e 'tell application "System Events" to set visible of every process to true'
    echo "FlashSpace quit and Stage Manager on"
else
    # FlashSpace is not running, turn it on
    defaults write com.apple.WindowManager GloballyEnabled -bool false
    open -jga "FlashSpace"
    echo "FlashSpace launched and Stage Manager off"
fi

