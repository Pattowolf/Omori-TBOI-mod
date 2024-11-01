local mod = OmoriMod
local game = Game()
local sfx = SFXManager()
local ShowEmotion = true
local room = game:GetRoom()

local renderTutText = false

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

	for i = 0, game:GetNumPlayers() - 1 do
		local room = game:GetRoom()
		local player = Isaac.GetPlayer(i)
		local playerData = OmoriMod:GetData(player)
		local pos = Isaac.WorldToScreen(player.Position)
		local XPositionAlter = -0.2
		local HeartY = pos.Y - (-1 * player.SpriteScale.Y * 1) - (1) * (1) - 50
		local x = pos.X - 6 * (XPositionAlter) 	
			
		if room:IsMirrorWorld() then
			x = (OmoriMod.GetScreenCenter().X*2 - x-16) + 16 
		end
			
		if player.ControlsEnabled == false then return end
			
		if not game:IsPaused() then 
			playerData.EmotionTitle = Sprite()
			if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
				local newEmotion = "Neutral"
				local pitch = 1
				local changeEmotion = {
					["Neutral"] = "Happy",
					["Happy"] = "Sad",
					["Sad"] = "Angry",
					["Angry"] = "Neutral",
				}
				local EmotionToChange = OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), changeEmotion)
				local emotionChange =
					Input.IsButtonTriggered(Keyboard.KEY_Z, player.ControllerIndex) or
					Input.IsButtonTriggered(Keyboard.KEY_LEFT_SHIFT, player.ControllerIndex) or
					Input.IsButtonTriggered(Keyboard.KEY_RIGHT_SHIFT, player.ControllerIndex) or
					Input.IsButtonTriggered(Keyboard.KEY_RIGHT_CONTROL, player.ControllerIndex) or
					Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)  
				
				if not playerData.OmoriCurrentEmotion then
					OmoriMod.SetEmotion(player, "Neutral")
				end
				
				if emotionChange then
					local upgradedEmotions = {
						["Ecstatic"] = "Sad",
						["Depressed"] = "Angry",
						["Enraged"] = "Neutral",
						["Manic"] = "Sad",
						["Miserable"] = "Angry",
						["Furious"] = "Neutral",
					}
					local newEmotion = OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), upgradedEmotions)
					OmoriMod.SetEmotion(player, newEmotion)
					OmoriMod.SetEmotion(player, EmotionToChange)
					OmoriMod:OmoriChangeEmotionEffect(player, true)
				end		
			elseif player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
				if not playerData.SunnyCurrentEmotion then
					OmoriMod.SetEmotion(player, "Neutral")
				end
			end
			if OmoriMod.GetEmotion(player) ~= nil then
				if emotionDisplayMenu == 1 or (emotionDisplayMenu == 2 and ShowEmotion == true) and DeadSeaScrollsMenu.OpenedMenu == nil then
					local emotionRoot = "gfx/Emotions" .. emotionLangSuffix .. ".png"
					playerData.EmotionTitle:Load("gfx/EmotionTitle.anm2")
					playerData.EmotionTitle:ReplaceSpritesheet(0, emotionRoot, true)
					playerData.EmotionTitle:Play(OmoriMod.GetEmotion(player), true)
					playerData.EmotionTitle:Render(Vector(x, HeartY), Vector.Zero, Vector.Zero)
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.RenderEmotionTitle)

function mod:RenderGlowInit(player)
	local playerData = OmoriMod:GetData(player)
	
	if not playerData.RenderEmotionGlow then
		if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI or player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
			playerData.RenderEmotionGlow = false
		else
			playerData.RenderEmotionGlow = nil
		end
	end
	
	if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
		if playerData.RenderEmotionGlow == true then
			playerData.RenderEmotionGlow = false
		end
	end
end
mod:AddCallback(TSIL.Enums.CustomCallback.POST_PLAYER_INIT_LATE, mod.RenderGlowInit)

function mod:RenderGlowUpdate(player)
	local playerData = OmoriMod:GetData(player)
	
	if playerData.RenderEmotionGlow == false then
		local emotionGlow = Isaac.Spawn(EntityType.ENTITY_EFFECT, OmoriMod.Enums.EffectVariant.EFFECT_EMOTION_GLOW, 0, player.Position, Vector.Zero, player):ToEffect()
		OmoriMod:ReplaceGlowSprite(player, emotionGlow)
		playerData.RenderEmotionGlow = true
	end

	local EmotionCostume = player:GetCostumeSpriteDescs()[3]

	for i = 4, 5 do
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PURITY) then
			player:GetCostumeSpriteDescs()[i]:GetSprite():ReplaceSpritesheet(0, "", true)
		end
	end
	
	if EmotionCostume == nil then
		if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
			OmoriMod:OmoriChangeEmotionEffect(player)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.RenderGlowUpdate)

function mod:EmotionGlowUpdate(effect)
	local player = effect.SpawnerEntity:ToPlayer()
	if player then
		effect.DepthOffset = -10
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.EmotionGlowUpdate, OmoriMod.Enums.EffectVariant.EFFECT_EMOTION_GLOW)

function mod:EmotionGlowColor(effect)
	local player = effect.SpawnerEntity:ToPlayer()
	if player then
		OmoriMod:ReplaceGlowSprite(player, effect)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.EmotionGlowColor, OmoriMod.Enums.EffectVariant.EFFECT_EMOTION_GLOW)