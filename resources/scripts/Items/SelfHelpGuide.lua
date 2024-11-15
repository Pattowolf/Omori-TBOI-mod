local mod = OmoriMod

local enums = OmoriMod.Enums
local tables = enums.Tables 
local misc = enums.Misc

local SelfHelpSetFrame = {
	["Neutral"] = tables.SelfHelpSpriteFrame.Neutral,
	["Happy"] = tables.SelfHelpSpriteFrame.Happy,
	["Sad"] = tables.SelfHelpSpriteFrame.Sad,
	["Angry"] = tables.SelfHelpSpriteFrame.Angry,
	["Ecstatic"] = tables.SelfHelpSpriteFrame.Happy,
	["Depressed"] = tables.SelfHelpSpriteFrame.Sad,
	["Enraged"] = tables.SelfHelpSpriteFrame.Angry,
	["Manic"] = tables.SelfHelpSpriteFrame.Happy,
	["Miserable"] = tables.SelfHelpSpriteFrame.Sad,
	["Furious"] = tables.SelfHelpSpriteFrame.Angry,
}

local SelfSprite = Sprite()
SelfSprite:Load('gfx/items/selfHelpGuide.anm2', true)

function mod:RenderSelfGuideMode(p, slot, offset, alpha, scale, chrgOffset)
	local item = p:GetActiveItem(slot)
	
	local renderPos = misc.SelfHelpRenderPos
	local renderScale = misc.SelfHelpRenderScale

	if item == OmoriMod.Enums.CollectibleType.COLLECTIBLE_SELF_HELP_GUIDE and p:IsCoopGhost() == false then
		local SelfHelpAnimFrame = OmoriMod.SwitchCase(OmoriMod.GetEmotion(p), SelfHelpSetFrame) or 0
		local pkitem = p:GetPocketItem(0)
		local ispocketactive = (pkitem:GetSlot() == 3 and pkitem:GetType() == 2)
		
		if slot == ActiveSlot.SLOT_SECONDARY or (not ispocketactive) then
			renderPos = renderPos / 2
			renderScale = renderScale / 2
		end
		
		SelfSprite:SetFrame("Idle", SelfHelpAnimFrame)
		SelfSprite.Scale = renderScale
		SelfSprite:Render(renderPos + offset, Vector.Zero, Vector.Zero)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, mod.RenderSelfGuideMode)

function mod:Mierda(collectible, player, var)
	return OmoriMod:IsOmori(player, false) and (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 2 or 4) or 3
end
mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, mod.Mierda, OmoriMod.Enums.CollectibleType.COLLECTIBLE_SELF_HELP_GUIDE)

function mod:SelfelpGuideUseOmori(_, _, player, flags)
	local playerData = OmoriMod:GetData(player)
	
	local CarBatteryUse = (flags == flags | UseFlag.USE_CARBATTERY)	
	local HasCarBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)

	if CarBatteryUse then return end
	
	local emotion = OmoriMod.GetEmotion(player)
	local IsMaxEmotionOrNeutral = OmoriMod.SwitchCase(emotion, tables.NoDischargeEmotions) or false
	if IsMaxEmotionOrNeutral == true then return {Discharge = false} end
	
	local tableRef = (
		OmoriMod:IsOmori(player, false) and (
			HasCarBattery and tables.SelfHelpEmotionUpgradesOmoriCarBattery or tables.SelfHelpEmotionUpgradesOmori
		) or (
			HasCarBattery and tables.SelfHelpEmotionUpgradesCarBattery or tables.SelfHelpEmotionUpgrades
		)
	)
	
	local EmotionToChange = OmoriMod.SwitchCase(emotion, tableRef)
	
	OmoriMod.SetEmotion(player, EmotionToChange)
	OmoriMod:OmoriChangeEmotionEffect(player, true)
	
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.SelfelpGuideUseOmori)

function mod:OnSelfHelpGuideTaking(_, _, _, _, _, player)
	local playerData = OmoriMod:GetData(player)
	
	if OmoriMod:IsAnyOmori(player) then return end 
	if OmoriMod.GetEmotion(player) == nil then
		OmoriMod.SetEmotion(player, "Neutral")
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, mod.OnSelfHelpGuideTaking, OmoriMod.Enums.CollectibleType.COLLECTIBLE_SELF_HELP_GUIDE)