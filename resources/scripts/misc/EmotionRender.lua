local mod = OmoriMod
local enums = OmoriMod.Enums
local utils = enums.Utils
local tables = enums.Tables
local game = utils.Game
local misc = enums.Misc

local funcs = {
	GetEmotion = mod.GetEmotion,
	SetEmotion = mod.SetEmotion,
	IsOmori = mod.IsOmori
}

local EmotionTitle = Sprite()
EmotionTitle:Load("gfx/EmotionTitle.anm2", true)

HudHelper.RegisterHUDElement({
	Name = "Emotion Title",
	Priority = HudHelper.Priority.LOW,
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
	end
}, HudHelper.HUDType.EXTRA)


function mod:RenderEmotionTitle()
	local p = Isaac.GetPlayer(0)
	local emotionLanguage = 1
	local emotionLangSuffix = ""
	
	if OmoriMod.saveManager.GetDeadSeaScrollsSave() then
		emotionLanguage = OmoriMod.saveManager.GetDeadSeaScrollsSave().emotionlanguage
	end

	if emotionLanguage == 2 then
		emotionLangSuffix = "_spa"
	end
	
	if Input.IsActionTriggered(ButtonAction.ACTION_MAP, p.ControllerIndex) then
		if ShowEmotion == false then
			ShowEmotion = true
		else
			ShowEmotion = false
		end
	end	
	
	if game:IsPaused() then return end
end

function mod:ChangeEmotionLogic(player)
	if not OmoriMod.IsOmori(player, false) then return end
	local emotion = funcs.GetEmotion(player)
	
	if not OmoriMod:IsEmotionChangeTriggered(player) then return end
	
	local newEmotion = tables.EmotionToChange[emotion] or "Neutral"
		
	OmoriMod.SetEmotion(player, newEmotion)
	OmoriMod:ChangeEmotionEffect(player, true)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.ChangeEmotionLogic)

---@param player EntityPlayer
function mod:EmotionGlow(player)
	local playerData = OmoriMod:GetData(player)
	local emotionGlow = playerData.EmotionGlow
	
	if OmoriMod.GetEmotion(player) == nil then return end
	
	if not emotionGlow then
		playerData.EmotionGlow = Isaac.Spawn(
			EntityType.ENTITY_EFFECT, 
			OmoriMod.Enums.EffectVariant.EFFECT_EMOTION_GLOW, 
			0, 
			player.Position, 
			Vector.Zero, 
			player
		):ToEffect()
		OmoriMod:ReplaceGlowSprite(player, playerData.EmotionGlow)
	else
		emotionGlow.Position = player.Position
		OmoriMod:ReplaceGlowSprite(player, playerData.EmotionGlow)
		emotionGlow.DepthOffset = -10
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.EmotionGlow)

function OmoriMod:RemoveEmotionGlow()
	local players = PlayerManager.GetPlayers()
	for _, player in ipairs(players) do
		local playerData = OmoriMod:GetData(player)
		if playerData.EmotionGlow then
			playerData.EmotionGlow = nil
		end
	end
end

function mod:RemoveOnRoom()
	OmoriMod:RemoveEmotionGlow()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OmoriMod.RemoveEmotionGlow)

function mod:OmoriOnNewLevel()
	local players = PlayerManager.GetPlayers()
	for _, player in ipairs(players) do
		if funcs.GetEmotion(player) == nil then return end

		OmoriMod:ChangeEmotionEffect(player, false)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.OmoriOnNewLevel)