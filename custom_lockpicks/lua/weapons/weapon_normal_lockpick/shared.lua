-- If you want to make more copy and paste this code into another. Its super easy just make another folder called "weapon_namehere_lockpick"
-- Inside of that new file put a shared.lua and paste this code below and edit it how you like
-- NOTES : LINE 9 IS THE NAME | LINE 23 IS HOW LONG TO PICK LOCK

if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Lockpick"
SWEP.Author = "6ixsvp"
SWEP.Instructions = "Left-click to start lockpicking."
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Category = "Custom Lockpicks"
SWEP.ViewModel = "models/weapons/c_crowbar.mdl" -- Crowbar model
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"
SWEP.LockpickTime = 15 -- Seconds

-- Set hold type
function SWEP:Initialize()
    self:SetHoldType("normal") -- Holds weapon at the player's side
end

if CLIENT then
    -- Variables for progress bar
    local lockpicking = false
    local startTime = 0
    local totalTime = 0

    net.Receive("StartLockpicking", function()
        lockpicking = true
        startTime = CurTime()
        totalTime = net.ReadFloat()
    end)

    net.Receive("StopLockpicking", function()
        lockpicking = false
    end)

    -- Draw progress bar UI
    hook.Add("HUDPaint", "DrawLockpickProgress", function()
        if not lockpicking then return end
        local progress = math.Clamp((CurTime() - startTime) / totalTime, 0, 1)
        draw.RoundedBox(5, ScrW() / 2 - 200, ScrH() / 2 + 100, 400, 25, Color(50, 50, 50, 200))
        draw.RoundedBox(5, ScrW() / 2 - 200, ScrH() / 2 + 100, 400 * progress, 25, Color(0, 255, 0, 255))
        draw.SimpleText("Lockpicking...", "DermaDefaultBold", ScrW() / 2, ScrH() / 2 + 112, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
end

-- Primary fire logic (lockpicking)
function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ply = self:GetOwner()
    local trace = ply:GetEyeTrace()

    if not IsValid(trace.Entity) or not trace.Entity:IsDoor() then
        ply:ChatPrint("You must aim at a door or lockable entity!")
        return
    end

    -- Start lockpicking
    self:SetNextPrimaryFire(CurTime() + self.LockpickTime)
    net.Start("StartLockpicking")
    net.WriteFloat(self.LockpickTime)
    net.Send(ply)

    timer.Create("LockpickTimer" .. ply:EntIndex(), self.LockpickTime, 1, function()
        if not IsValid(ply) then return end
        if not IsValid(trace.Entity) then return end

        trace.Entity:Fire("Unlock")
        trace.Entity:Fire("Open")
        ply:ChatPrint("Lockpicking successful!")

        net.Start("StopLockpicking")
        net.Send(ply)
    end)
end

-- Disable secondary attack
function SWEP:SecondaryAttack()
    return
end
