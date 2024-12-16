local mod = OmoriMod

local enums = OmoriMod.Enums
local enemyRadius = 80
local costumes = enums.NullItemID
local utils = enums.Utils

local sfx = utils.SFX

---comment
---@param player EntityPlayer
function mod:SunnyInit(player)
    if not OmoriMod:IsOmori(player, true) then return end

	local playerData = OmoriMod:GetData(player)
    
	playerData.AfraidCounter = playerData.AfraidCounter or 90
    playerData.StressCounter = playerData.StressCounter or 150
    playerData.TriggerAfraid = playerData.TriggerAfraid or false
    playerData.TriggerStress = playerData.TriggerStress or false
	
    player:AddNullCostume(costumes.ID_SUNNY)
    player:AddNullCostume(costumes.ID_EMOTION)

    OmoriMod.SetEmotion(player, "Neutral")
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.SunnyInit)

local AfraidColor = Color(1, 1, 1, 1, 0.2, 0.2, 0.2)
local StressColor = Color(1, 1, 1, 1, 0.2)


---comment
---@param player EntityPlayer
---@return boolean
function mod:AreEnemiesNearby(player)
    local nearEnemies = Isaac.FindInRadius(player.Position, enemyRadius, EntityPartition.ENEMY)

    local Bool = false

    for _, enemy in ipairs(nearEnemies) do
        if enemy:IsActiveEnemy() and enemy:IsVulnerableEnemy() then
            Bool = true
        end
    end

    return Bool
end

---comment
---@param player EntityPlayer
function mod:SunnyStressingOut(player)
    if not OmoriMod:IsOmori(player, true) then return end

    OmoriMod:GiveKnife(player)

    local emotion = OmoriMod.GetEmotion(player)
	local playerData = OmoriMod:GetData(player)    
    local areNearEnemies = mod:AreEnemiesNearby(player)

    if areNearEnemies then
        if emotion ~= "StressedOut" then
            local counterToDecrease = (emotion == "Afraid") and "StressCounter" or "AfraidCounter"
            playerData[counterToDecrease] = math.max(playerData[counterToDecrease] - 1, 0)
        end
    else
        playerData.AfraidCounter = 90
        playerData.StressCounter = 150
    end
    

    local emotions = {
        Afraid = "AfraidCounter",
        StressedOut = "StressCounter"
    }

    for emotion, counter in pairs(emotions) do
        local color = (emotion == "Afraid" and AfraidColor) or StressColor

        if playerData[counter] == 1 then
            OmoriMod.SetEmotion(player, emotion)
            OmoriMod:SunnyChangeEmotionEffect(player)
            player:SetColor(color, 8, -1, true, true)
            playerData[counter] = 0
        end

        if playerData[counter] <= 30 and playerData[counter] > 0 and playerData[counter] % 10 == 0 then
            sfx:Play(SoundEffect.SOUND_BEEP)
            player:SetColor(color, 8, -1, true, true)
        end
    end    
    
    print(playerData.AfraidCounter, playerData.StressCounter)
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.SunnyStressingOut)