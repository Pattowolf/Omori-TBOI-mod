local mod = OmoriMod
local sfx = SFXManager()
local enemyRadius = 80

function mod:SunnyInit(player)
	local playerData = OmoriMod:GetData(player)
    if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then	
		playerData.AfraidCounter = playerData.AfraidCounter or 90
        playerData.StressCounter = playerData.StressCounter or 150
        playerData.TriggerAfraid = playerData.TriggerAfraid or false
        playerData.TriggerStress = playerData.TriggerStress or false
	
        player:AddNullCostume(OmoriMod.Enums.NullItemID.ID_SUNNY)
    end
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
        
        if playerData.AfraidCounter == 1 then
            OmoriMod.SetEmotion(player, "Afraid")
            OmoriMod:SunnyChangeEmotionEffect(player, true)
			playerData.AfraidCounter = 0
        end
        
        if playerData.StressCounter == 1 then
            OmoriMod.SetEmotion(player, "StressedOut")
            OmoriMod:SunnyChangeEmotionEffect(player, true)
			playerData.StressCounter = 0
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.SunnyStressingOut)