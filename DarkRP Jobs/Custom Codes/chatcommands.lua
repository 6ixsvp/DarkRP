--[[ 
Custom Chat Commands Script for Garry's Mod
===========================================
1. Place this file in `lua/autorun/server`.
2. Edit the "commands" table below to add or modify chat commands.
3. Commands are case-insensitive. Type `!command` in the chat box to use.
--]]

-- Table of commands and their responses (edit this to add/update links)
local commands = {
    ["!discord"] = "Join our Discord server here: https://discord.gg/yourlink", -- Replace "yourlink" with your actual Discord invite link.
    ["!steamgroup"] = "Check out our Steam group here: https://steamcommunity.com/groups/yourgroup", -- Replace "yourgroup" with your actual Steam group link.
    ["!addons"] = "Download missing addons here: https://youraddonslink.com", -- Replace "youraddonslink.com" with your addons/download content link.
}

-- Hook to listen for chat messages
hook.Add("PlayerSay", "CustomChatCommands", function(ply, text, teamChat)
    text = string.lower(text) -- Make input case-insensitive

    -- Check if the entered text matches a command
    if commands[text] then
        ply:ChatPrint(commands[text]) -- Send the matching response to the player
        return "" -- Prevent the message from showing in the chat
    end
end)

--[[ 
How to Add More Commands:
1. Add a new entry to the "commands" table above, using the format:
   ["!yourcommand"] = "Your response here: yourlink",

2. Example:
   ["!website"] = "Visit our website here: https://yourwebsite.com",

3. Save the file, and the new command will work immediately after restarting the server or refreshing the script.
--]]
