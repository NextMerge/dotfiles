#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Dismiss Notifications
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔕
# @raycast.author NextMerge
# @raycast.authorURL https://raycast.com/NextMerge

tell application "System Events"
	tell process "NotificationCenter"
		if not (window "Notification Center" exists) then return
		
		set notificationContainer to group 1 of scroll area 1 of group 1 of group 1 of window "Notification Center"
		
		repeat
			set dismissedSomething to false
			
			-- Capture the current groups as a real list.
			try
				set notificationGroups to get every group of notificationContainer
			on error
				set notificationGroups to {}
			end try
			
			-- Work backwards because dismissing an item changes the indexes.
			repeat with i from (count of notificationGroups) to 1 by -1
				try
					set currentGroup to item i of notificationGroups
					
					set matchingActions to (actions of currentGroup whose description is "Close" or description starts with "Clear")
					
					if (count of matchingActions) > 0 then
						perform item 1 of matchingActions
						set dismissedSomething to true
					end if
				end try
			end repeat
			
			-- Reacquire the container's own action after the hierarchy changes.
			try
				set matchingActions to actions of notificationContainer whose description is "Close" or description starts with "Clear"
				
				if (count of matchingActions) > 0 then
					perform item 1 of matchingActions
					set dismissedSomething to true
				end if
			end try
			
			-- Stop when there is nothing left to dismiss.
			if not dismissedSomething then exit repeat
		end repeat
	end tell
end tell

return