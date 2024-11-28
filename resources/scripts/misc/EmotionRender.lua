local mod = OmoriMod
local enums = OmoriMod.Enums
local utils = enums.Utils
local tables = enums.Tables
local game = utils.Game

function mod:RenderEmotionTitle()
	local p = Isaac.GetPlayer(0)
	local emotionDisplayMenu = 1
	local emotionLanguage = 1
	local emotionLangSuffix = ""
	
	if OmoriMod.saveManager.GetDeadSeaScrollsSave() then
		emotionDisplayMenu = OmoriMod.saveManager.GetDeadSeaScrollsSave().emotiondisplay
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

	local players = PlayerManager.GetPlayers()
	
	if game:IsPaused() then return end
	
	for _, player in ipairs(players) do
		local playerData = OmoriMod:GetData(player)
	
		local emotion = OmoriMod.GetEmotion(player)
		if emotion == nil then return end
	
		local pos = Isaac.WorldToScreen(player.Position)
		local XPositionAlter = -0.2
		local y = pos.Y - (-1 * player.SpriteScale.Y * 1) - (1) * (1) - 50
		local x = pos.X - 6 * (XPositionAlter) 	
	
		local room = game:GetRoom()
	
		if room:IsMirrorWorld() then
			x = (OmoriMod.GetScreenCenter().X*2 - x-16) + 16 
		end
		
		if not playerData.EmotionTitle then
			playerData.EmotionTitle = Sprite()
			playerData.EmotionTitle:Load("gfx/EmotionTitle.anm2", true)
		end
				
		local emotionRoot = "gfx/Emotions" .. emotionLangSuffix .. ".png"
		playerData.EmotionTitle:ReplaceSpritesheet(0, emotionRoot, true)
		playerData.EmotionTitle:Play(emotion, true)
		playerData.EmotionTitle:Render(Vector(x, y), Vector.Zero, Vector.Zero)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.RenderEmotionTitle)

function mod:ChangeEmotionLogic(player)
	if not OmoriMod:IsOmori(player, false) then return end
	local emotion = OmoriMod.GetEmotion(player)

	if emotion == nil then
		OmoriMod.SetEmotion(player, "Neutral")
	end
	
	if not OmoriMod:IsEmotionChangeTriggered(player) then return end
	local newEmotion = tables.EmotionToChange[emotion] or "Neutral"
		
	OmoriMod.SetEmotion(player, newEmotion)
	OmoriMod:OmoriChangeEmotionEffect(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.ChangeEmotionLogic)

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