#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Bear Open Today
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐻

# Documentation:
# @raycast.author NextMerge
# @raycast.authorURL https://raycast.com/NextMerge

today=$(date +%Y-%m-%d)

open "bear://x-callback-url/open-note?title=$today&edit=yes&x-error=raycast://script-commands/bear-createtoday"

