-- **AFK System Addon for DarkRP**
if SERVER then
    util.AddNetworkString("AFKNotify")

    -- Editable Settings (Server Owners)
    local AFK_JOB = TEAM_CITIZEN -- Default AFK job (edit this to your AFK job if different)
    local REWARD_ENABLED = true -- Set to false to disable AFK rewards
    local REWARD_AMOUNT = 100 -- In-game money earned per minute while AFK

    -- Function to set a player as AFK
    local function setPlayerAFK(ply)
        if ply:isArrested() then
            ply:ChatPrint("[AFK] You cannot go AFK while arrested.")
            return
        end

        -- Save the player's current job for reference
        ply.previousJob = ply:Team()

        -- Switch the player to the AFK job
        if not AFK_JOB then
            ply:ChatPrint("[AFK] AFK job not found! Please set a valid AFK job in the script.")
            return
        end
        ply:SetTeam(AFK_JOB)
        ply:StripWeapons()
        ply:ChatPrint("[AFK] You are now AFK. You cannot move or interact until you select a new job.")

        -- Lock the player in place
        ply:SetMoveType(MOVETYPE_NONE)

        -- Notify everyone about the player's AFK status
        net.Start("AFKNotify")
        net.WriteString(ply:Nick())
        net.Broadcast()

        -- Optional: Reward System
        if REWARD_ENABLED then
            timer.Create("AFKReward_" .. ply:SteamID(), 60, 0, function()
                if not IsValid(ply) or ply:Team() ~= AFK_JOB then
                    timer.Remove("AFKReward_" .. ply:SteamID())
                    return
                end
                ply:addMoney(REWARD_AMOUNT)
                ply:ChatPrint("[AFK] You have earned $" .. REWARD_AMOUNT .. " for being AFK.")
            end)
        end
    end

    -- Function to unset a player as AFK
    local function unsetPlayerAFK(ply)
        -- Unlock player movement
        ply:SetMoveType(MOVETYPE_WALK)

        -- Stop AFK reward timer
        timer.Remove("AFKReward_" .. ply:SteamID())

        ply:ChatPrint("[AFK] You are no longer AFK. Please select a job to continue playing!")
    end

    -- Chat command to toggle AFK mode
    hook.Add("PlayerSay", "AFKCommand", function(ply, text)
        if string.lower(text) == "/afk" then
            if ply:Team() == AFK_JOB then
                ply:ChatPrint("[AFK] You are already in AFK mode!")
                return ""
            end
            setPlayerAFK(ply)
            return ""
        end
    end)

    -- Reset AFK restrictions when the player changes their job
    hook.Add("OnPlayerChangedTeam", "AFKTeamChange", function(ply, oldTeam, newTeam)
        if oldTeam == AFK_JOB then
            unsetPlayerAFK(pl
