local mod = OmoriMod
local enums = mod.Enums
local tables = enums.Tables


---comment
---@param player EntityPlayer
function mod:InitFarawayAubrey(player)
    if not OmoriMod:IsAubrey(player, true) then return end

    local playerData = OmoriMod:GetData(player)

    playerData.HeadButtTimer = 90
    playerData.HeadButt = false
    
    OmoriMod.SetEmotion(player, "Neutral")
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.InitFarawayAubrey)

---comment
---@param entity Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
---@return boolean?
function mod:OnFarawayAubreyDamaged(entity, amount, flags, source, countdown)
    local player = entity:ToPlayer()

    if not player then return end

    if not OmoriMod:IsAubrey(player, true) then return end

    local emotion = OmoriMod.GetEmotion(player)
    local playerData = OmoriMod:GetData(player)

    if emotion == "Neutral" then
        OmoriMod.SetEmotion(player, "Angry")
        playerData.HeadButtTimer = 15
    elseif emotion == "Angry" then    
        OmoriMod.SetEmotion(player, "Enraged")
        playerData.HeadButtTimer = 30
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.OnFarawayAubreyDamaged)

---comment
---@param player EntityPlayer
function mod:AubreyHeadbuttTimer(player)
    if not OmoriMod:IsAubrey(player, true) then return end
    local playerData = OmoriMod:GetData(player)

    if playerData.HeadButtTimer > 0 then
        playerData.HeadButtTimer = playerData.HeadButtTimer - 1 
    else
        mod:InitHeadbutt(player)
    end

    print(playerData.HeadButtTimer, playerData.HeadButt)

    if playerData.HeadButt == true then
        player.Velocity = playerData.HeadButtDir
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.AubreyHeadbuttTimer)

---comment
---@param player EntityPlayer
function mod:FarawayAubreyUpdate(player)
    if not OmoriMod:IsAubrey(player, true) then return end

    local playerData = OmoriMod:GetData(player)

    if player:CollidesWithGrid() then
        if playerData.HeadButt == true then
            mod:TriggerHBParams(player)

            playerData.HeadButtTimer = 900
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.FarawayAubreyUpdate)