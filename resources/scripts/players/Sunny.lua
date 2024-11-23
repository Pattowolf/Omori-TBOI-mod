local mod = OmoriMod

local enums = OmoriMod.Enums
local enemyRadius = 80
local costumes = enums.NullItemID

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

function mod:SunnyStressingOut(player)
	local playerData = OmoriMod:GetData(player)
    local playerType = player:GetPlayerType()
    
    if playerType == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
        local nearEnemies = Isaac.FindInRadius(player.Position, enemyRadius, EntityPartition.ENEMY)
        
		playerData.NearEnemy = #nearEnemies > 0
        
		if not playerData.NearEnemy then
			playerData.NearEnemy = false
		end
		
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
        
        for emotion, counter in pairs(emotions) do
            if playerData[counter] == 1 then
                OmoriMod.SetEmotion(player, emotion)
                OmoriMod:SunnyChangeEmotionEffect(player)
                playerData[counter] = 0
            end
        end        
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.SunnyStressingOut)