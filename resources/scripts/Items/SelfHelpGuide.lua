local SelfHelpGuide = {}
local mod = OmoriMod
local modrng = RNG()
local game = Game()

local SelfHelpSpriteFrame = {
	Neutral = 0,
	Happy = 1,
	Sad = 2,
	Angry = 3,
}

function mod:RenderSelfGuideMode(p, slot, offset, alpha, scale, chrgOffset)

	print(alpha, scale)

	local item = p:GetActiveItem(slot)
	local SelfSprite = Sprite()
	SelfSprite:Load('gfx/items/selfHelpGuide.anm2', true)
	
	if item == OmoriMod.Enums.CollectibleType.COLLECTIBLE_SELF_HELP_GUIDE and p:IsCoopGhost() == false then
		local SelfHelpAnimFrame = 0
		
		local pkitem = p:GetPocketItem(0)
		local ispocketactive = (pkitem:GetSlot() == 3 and pkitem:GetType() == 2)
			
		local renderPos = Vector(16, 16)
		local renderScale = Vector(1, 1)
		
		local emotion = {
			["Neutral"] = SelfHelpSpriteFrame.Neutral,
			["Happy"] = SelfHelpSpriteFrame.Happy,
			["Sad"] = SelfHelpSpriteFrame.Sad,
			["Angry"] = SelfHelpSpriteFrame.Angry,
			["Ecstatic"] = SelfHelpSpriteFrame.Happy,
			["Depressed"] = SelfHelpSpriteFrame.Sad,
			["Enraged"] = SelfHelpSpriteFrame.Angry,
			["Manic"] = SelfHelpSpriteFrame.Happy,
			["Miserable"] = SelfHelpSpriteFrame.Sad,
			["Furious"] = SelfHelpSpriteFrame.Angry,
		}
			
		SelfHelpAnimFrame = OmoriMod.SwitchCase(OmoriMod.GetEmotion(p), emotion) or 0
		
		if SelfHelpAnimFrame < 4 then
			if slot == ActiveSlot.SLOT_PRIMARY then
			elseif slot == ActiveSlot.SLOT_SECONDARY or (not ispocketactive) then
				renderPos = renderPos / 2
				renderScale = renderScale / 2
			end
			SelfSprite:SetFrame("Idle", SelfHelpAnimFrame)
			SelfSprite.Scale = renderScale
			
			SelfSprite.Color = Color(1, 1, 1, alpha, 0, 0, 0)
			-- SelfSprite.Rotation = 90
			
			SelfSprite:Render(renderPos + offset, Vector.Zero, Vector.Zero)
			
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, mod.RenderSelfGuideMode)

function mod:Mierda(collectible, player, var)
	local Charge = 3
	if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
		Charge = 6
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			Charge = 4
		end
	end
	return Charge
end
mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, mod.Mierda, OmoriMod.Enums.CollectibleType.COLLECTIBLE_SELF_HELP_GUIDE)


function SelfHelpGuide:SelfHelpGuideUse(id, RNG, player, flags, slot, CustomData)
	local playerData = OmoriMod:GetData(player)

	local carBatteryUse = flags == flags | UseFlag.USE_CARBATTERY

	-- print(flags == flags | UseFlag.USE_CARBATTERY)

	if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then return end		
	
	playerData.ChangeCustome = false
	
	local emotions = {
		["Neutral"] = function()
			local emotionChange = "Happy"
			if carBatteryUse then
				emotionChange = "Ecstatic"
			end
			
			OmoriMod.SetEmotion(player, emotionChange)
		end,
		["Happy"] = function()
			local emotionChange = "Sad"
			if carBatteryUse then
				emotionChange = "Depressed"
			end
			OmoriMod.SetEmotion(player, emotionChange)
		end,
		["Sad"] = function()
			local emotionChange = "Angry"
			if carBatteryUse then
				emotionChange = "Enraged"
			end
			OmoriMod.SetEmotion(player, emotionChange)
		end,
		["Angry"] = function()
			local emotionChange = "Happy"
			if carBatteryUse then
				emotionChange = "Ecstatic"
			end
			OmoriMod.SetEmotion(player, "Happy")
		end,
		["Ecstatic"] = function()
			if carBatteryUse == true then
				OmoriMod.SetEmotion(player, "Depressed")
			else
				OmoriMod.SetEmotion(player, "Sad")
			end
		end,
		["Depressed"] = function()
			if carBatteryUse == true then
				OmoriMod.SetEmotion(player, "Enraged")
			else
				OmoriMod.SetEmotion(player, "Angry")
			end
		end,
		["Enraged"] = function()
			if carBatteryUse == true then
				OmoriMod.SetEmotion(player, "Ecstatic")
			else
				OmoriMod.SetEmotion(player, "Happy")
			end
		end,
	}
	OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), emotions)
	if not playerData.RenderEmotionGlow then
		playerData.RenderEmotionGlow = false
	end

	return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, SelfHelpGuide.SelfHelpGuideUse, OmoriMod.Enums.CollectibleType.COLLECTIBLE_SELF_HELP_GUIDE)


function SelfHelpGuide:SelfHelpGuideUseOmori(id, RNG, player, flags, slot, CustomData)
	local playerData = OmoriMod:GetData(player)
	if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
		if not playerData.UsedSelfHelpGuide then
			playerData.UsedSelfHelpGuide = false
		end
		
		-- local CarBatteryUse = (flags == flags | UseFlag.USE_CARBATTERY)
		-- print(flags == flags | UseFlag.USE_CARBATTERY)
		
		local NoDischargeEmotions = {
			"Neutral",
			"Manic",
			"Miserable",
			"Furious",
		}
		
		if not playerData.SelfHelpChangeEmotion then
			playerData.SelfHelpChangeEmotion = false
		end
		
		for key, value in pairs(NoDischargeEmotions) do
			if OmoriMod.GetEmotion(player) == value then
				return {Discharge = false}
			end
		end
		
		if OmoriMod.GetEmotion(player) ~= "Neutral" then
			playerData.UsedSelfHelpGuideOnNeutral = true
			
		else 
			playerData.UsedSelfHelpGuideOnNeutral = true
		end
		
		if OmoriMod.GetEmotion(player) == "Happy" then
			OmoriMod.SetEmotion(player, "Ecstatic")
		elseif OmoriMod.GetEmotion(player) == "Ecstatic" then
			OmoriMod.SetEmotion(player, "Manic")
		elseif OmoriMod.GetEmotion(player) == "Sad" then
			OmoriMod.SetEmotion(player, "Depressed")
		elseif OmoriMod.GetEmotion(player) == "Depressed" then
			OmoriMod.SetEmotion(player, "Miserable")
		elseif OmoriMod.GetEmotion(player) == "Angry" then
			OmoriMod.SetEmotion(player, "Enraged")
		elseif OmoriMod.GetEmotion(player) == "Enraged" then
			OmoriMod.SetEmotion(player, "Furious")
		end

		OmoriMod:OmoriChangeEmotionEffect(player, true)

		playerData.TriggerEmotionChange = true
		return true
	end	
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, SelfHelpGuide.SelfHelpGuideUseOmori)

function SelfHelpGuide:OnSelfHelpGuideTaking(player)
	local playerData = OmoriMod:GetData(player)
	if player:GetPlayerType() ~= OmoriMod.Enums.PlayerType.PLAYER_OMORI or player:GetPlayerType() ~= OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
		if player:HasCollectible(OmoriMod.Enums.CollectibleType.COLLECTIBLE_SELF_HELP_GUIDE) then
			if OmoriMod.GetEmotion(player) == nil then
				OmoriMod.SetEmotion(player, "Neutral")
			end
		else
			playerData.PlayerEmotion = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SelfHelpGuide.OnSelfHelpGuideTaking)