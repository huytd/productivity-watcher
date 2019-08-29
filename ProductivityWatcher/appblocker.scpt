tell application "System Events" to set all_apps to the name of every process whose visible is true

set blacklist to {"slack", "firefox", "gmail", "calendar"}

repeat with a in all_apps
set found to 0
repeat with b in blacklist
if b is in a then
set found to 1
end if
end repeat
if found is 1 then
tell application "System Events"
tell process a
repeat with aWindow in windows
set aWindow to contents of aWindow
if aWindow is not missing value and ¬
(exists attribute "AXMinimized" of aWindow) then ¬
set value of attribute "AXMinimized" of aWindow to true
end repeat
end tell
end tell
end if
end repeat
