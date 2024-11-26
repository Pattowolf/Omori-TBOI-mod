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
    player:AddNullCostume(costumes.ID_SUNNY_EMOTION)

    OmoriMod.SetEmotion(player, "Neutral")
end
mod:AddCallback(TSIL.Enums.CustomCallback.POST_PLAYER_INIT_LATE, mod.SunnyInit)

local AfraidColor = Color(1, 1, 1, 1, 0.2, 0.2, 0.2)
local StressColor = Color(1, 1, 1, 1, 0.2)

---@param player EntityPlayer
function mod:SunnyStressingOut(player)
    if not OmoriMod:IsOmori(player, true) then return end
	local playerData = OmoriMod:GetData(player)    
    local nearEnemies = Isaac.FindInRadius(player.Position, enemyRadius, EntityPartition.ENEMY)
        
	playerData.NearEnemy = false or #nearEnemies > 0

    if playerData.NearEnemy then
        if OmoriMod.GetEmotion(player) ~= "StressedOut" then
            if OmoriMod.GetEmotion(player) == "Afraid" then
                playerData.StressCounter = math.max(playerData.StressCounter - 1, 0)
            else
                playerData.AfraidCounter = math.max(playerData.AfraidCounter - 1, 0)
            end
        end
    else
        playerData.AfraidCounter = 90
        playerData.StressCounter = 150
    end

    local emotions = {
        Afraid = "AfraidCounter",
        StressedOut = "StressCounter"
    }
    
    print(OmoriMod:GetPtrHashEntity(player))

    for emotion, counter in pairs(emotions) do
        local color = OmoriMod.GetEmotion(player) == "Afraid" and StressColor or AfraidColor

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
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.SunnyStressingOut)