local mod = OmoriMod
local enums = OmoriMod.Enums
local tables = enums.Tables
local misc = enums.Misc

local funcs = {
	GetEmotion = mod.GetEmotion,
	SetEmotion = mod.SetEmotion,
	IsOmori = mod.IsOmori,
	GetData = mod.GetData,
	TriggerEmoChange = mod.IsEmotionChangeTriggered,
	Switch = mod.When,
}

local EmotionTitle = Sprite("gfx/EmotionTitle.anm2", true)

HudHelper.RegisterHUDElement({
	Name = "Emotion Title",
	Priority = HudHelper.Priority.EID,
	XPadding = 0,
	YPadding = 0,
	Condition = function(player)
		return funcs.GetEmotion(player) ~= nil
	end,
	OnRender = function(player)
		if RoomTransition:GetTransitionMode() == 3 then return end

		local emotion = funcs.GetEmotion(player)
		EmotionTitle:Play(emotion, true)
        EmotionTitle:Render(Isaac.WorldToScreen(player.Position + misc.EmotionTitleOffset), Vector.Zero, Vector.Zero)
	end,
	PreRenderCallback = true,
}, HudHelper.HUDType.EXTRA)

function mod:ChangeEmotionLogic(player)
	if not OmoriMod.IsOmori(player, false) then return end
	local emotion = funcs.GetEmotion(player)

	if not OmoriMod:IsEmotionChangeTriggered(player) then return end
	local newEmotion = funcs.Switch(emotion, tables.EmotionToChange, "Neutral")

	funcs.SetEmotion(player, newEmotion)
	OmoriMod:ChangeEmotionEffect(player, true)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.ChangeEmotionLogic)

-- function OmoriMod:RemoveEmotionGlow()
-- 	local players = PlayerManager.GetPlayers()
-- 	for _, player in ipairs(players) do
-- 		local playerData = OmoriMod.GetData(player)
-- 		if playerData.EmotionGlow then
-- 			playerData.EmotionGlow = nil
-- 		end
-- 	end
-- end

-- function mod:RemoveOnRoom()
-- 	OmoriMod:RemoveEmotionGlow()
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OmoriMod.RemoveEmotionGlow)

function mod:OmoriOnNewLevel()
	local players = PlayerManager.GetPlayers()
	for _, player in ipairs(players) do
		if funcs.GetEmotion(player) == nil then return end
		OmoriMod:ChangeEmotionEffect(player, false)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.OmoriOnNewLevel)