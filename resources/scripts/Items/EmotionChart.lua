local mod = OmoriMod

local enums = OmoriMod.Enums
local tables = enums.Tables 
local misc = enums.Misc
local emotionFrame = tables.EmotionChartFrame
local items = enums.CollectibleType

local EmotionChartSetFrame = {
	["Neutral"] = emotionFrame.Neutral,
	["Happy"] = emotionFrame.Happy,
	["Sad"] = emotionFrame.Sad,
	["Angry"] = emotionFrame.Angry,
	["Ecstatic"] = emotionFrame.Happy,
	["Depressed"] = emotionFrame.Sad,
	["Enraged"] = emotionFrame.Angry,
	["Manic"] = emotionFrame.Happy,
	["Miserable"] = emotionFrame.Sad,
	["Furious"] = emotionFrame.Angry,
}

local SelfSprite = Sprite()
SelfSprite:Load('gfx/items/emotionChart.anm2', true)

function mod:RenderSelfGuideMode(p, slot, offset)
	local item = p:GetActiveItem(slot)
	local emotion = OmoriMod.GetEmotion(p)
	local renderPos = misc.SelfHelpRenderPos
	local renderScale = misc.SelfHelpRenderScale

	if item == items.COLLECTIBLE_EMOTION_CHART and p:IsCoopGhost() == false then
		local SelfHelpAnimFrame = EmotionChartSetFrame[emotion] or 0
		local pkitem = p:GetPocketItem(0)
		local ispocketactive = (pkitem:GetSlot() == 3 and pkitem:GetType() == 2)

		if slot == ActiveSlot.SLOT_SECONDARY or (OmoriMod:IsOmori(p, false) and not ispocketactive) then
			renderPos = renderPos / 2
			renderScale = renderScale / 2
		end
		
		SelfSprite:SetFrame("Idle", SelfHelpAnimFrame)
		SelfSprite.Scale = renderScale
		SelfSprite:Render(renderPos + offset, Vector.Zero, Vector.Zero)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, mod.RenderSelfGuideMode)

function mod:Mierda(_, player)
	return OmoriMod:IsOmori(player, false) and (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 2 or 4) or 3
end
mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, mod.Mierda, items.COLLECTIBLE_EMOTION_CHART)

local conditionMap = {
    [true] = {[true] = tables.EmotionUpgradesOmoriCarBattery, [false] = tables.EmotionUpgradesOmori},
    [false] = {[true] = tables.EmotionUpgradesCarBattery, [false] = tables.EmotionUpgrades}
}

function mod:SelfelpGuideUseOmori(_, _, player, flags)
	local CarBatteryUse = (flags == flags | UseFlag.USE_CARBATTERY)	
	
	if CarBatteryUse then return end
	local HasCarBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
	local emotion = OmoriMod.GetEmotion(player)
	local IsMaxEmotionOrNeutral = tables.NoDischargeEmotions[emotion] or false
	
	if IsMaxEmotionOrNeutral == true then return {Discharge = false} end
	
	local tableRef = conditionMap[OmoriMod:IsOmori(player, false)][HasCarBattery]
	
	local EmotionToChange = tableRef[emotion]
	
	OmoriMod.SetEmotion(player, EmotionToChange)
	
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.SelfelpGuideUseOmori, items.COLLECTIBLE_EMOTION_CHART)

function mod:OnSelfHelpGuideTaking(_, _, _, _, _, player)
	if OmoriMod:IsAnyOmori(player) then return end 
	if OmoriMod.GetEmotion(player) == nil then
		OmoriMod.SetEmotion(player, "Happy")
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, mod.OnSelfHelpGuideTaking, items.COLLECTIBLE_EMOTION_CHART)