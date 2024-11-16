local mod = OmoriMod
local enums = OmoriMod.Enums

local utils = enums.Utils
local tables = enums.Tables

local game = utils.Game
local modrng = utils.RNG
local sfx = utils.SFX

local dp_tookDamage = false

function mod:dp_onStart()
	dp_tookDamage = false
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.dp_onStart)

function mod:EmotionDamageManager(player, damage, flags, source, cooldown)
	local CustomDamageTrigger = OmoriMod.randomNumber(1, 100, modrng)
	
	local birthrightSadMult = 1
	local birthrightAngryMult = 1
	
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		birthrightSadMult = 1.25
		birthrightAngryMult = 1.1
	end
	
	local sadTier = {
		["Sad"] = 25,
		["Depressed"] = 35,
		["Miserable"] = 50,
	}
				
	local angryTier = {
		["Angry"] = 50,
		["Enraged"] = 70,
		["Furious"] = 85,
	}
		
	local SadIgnoreChance = OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), sadTier) or 0
	local AngryDoubleChance = OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), angryTier) or 0
	
	if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
		if OmoriMod.GetEmotion(player) == "Afraid" or OmoriMod.GetEmotion(player) == "StressedOut" then
			if dp_tookDamage == false then
				dp_tookDamage = true
				player:TakeDamage(damage * 2, flags, source, cooldown)
				return false
			end
		end
	else
		if player:GetDamageCooldown() == 0 then	
			if (CustomDamageTrigger <= math.ceil(SadIgnoreChance * birthrightSadMult)) and (SadIgnoreChance > 0) then
				local baseiFrames = 60
				local iFramesMult = 1 + (SadIgnoreChance / 100)			
				local chanceToRemoveCharge = OmoriMod.randomNumber(1, 100, rng)
						
				if player:HasTrinket(TrinketType.TRINKET_BLIND_RAGE) then
					baseiFrames = 120
				end

				if chanceToRemoveCharge <= math.ceil(SadIgnoreChance * birthrightSadMult) then
					local randomSlotSelect = OmoriMod.randomNumber(1, 3)
					
					local possiblePockets = {
						[1] = ActiveSlot.SLOT_PRIMARY,
						[2] = ActiveSlot.SLOT_SECONDARY,
						[3] = ActiveSlot.SLOT_POCKET,
					}
				
					local SlotMain = ActiveSlot.SLOT_PRIMARY
					local SlotPocket = ActiveSlot.SLOT_POCKET
					
					local activeCharge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
					if activeCharge > 0 then
						sfx:Play(SoundEffect.SOUND_BATTERYDISCHARGE, 1, 0, false, 1, 0)
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 3, player.Position + Vector(0, 10), Vector.Zero, player)
						player:SetActiveCharge(activeCharge - 1, ActiveSlot.SLOT_PRIMARY)
						game:GetHUD():FlashChargeBar(player, ActiveSlot.SLOT_PRIMARY)
					end
					return false
				end
				player:SetMinDamageCooldown(baseiFrames * iFramesMult)	
			elseif (CustomDamageTrigger <= AngryDoubleChance) and (AngryDoubleChance > 0) then
				if dp_tookDamage == false then
					dp_tookDamage = true
					player:TakeDamage(damage * 2, flags, source, cooldown)
					return false
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, mod.EmotionDamageManager)

function mod:OnShootHappyTear(tear)
	OmoriMod.DoHappyTear(tear)	
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.OnShootHappyTear)
-- Happy tears Manager end

-- Stats Manager
function mod:OmoStats(player, flag)
	local currentEmotion = OmoriMod.GetEmotion(player)
	local hasBirthright = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	
	if not OmoriMod:IsOmori(player, true) then
		if flag == CacheFlag.CACHE_DAMAGE then
			local DamageEmotion = OmoriMod.SwitchCase(currentEmotion, tables.DamageAlterEmotions)
			
			if OmoriMod:IsOmori(player, false) then
				player.Damage = player.Damage * 0.8
			end
			
			if not DamageEmotion then return end
						
			local EmotionDamageMult = DamageEmotion.EmotionDamageMult
			local damageMult = DamageEmotion.damageMult
			local birthrightMult = DamageEmotion.birthrightMult
				
			local baseDamage = player.Damage

			if OmoriMod:IsOmori(player, false) then
				local birthrightMultiplier = hasBirthright and birthrightMult or 1
				player.Damage = (baseDamage * damageMult * EmotionDamageMult * birthrightMultiplier)
			else
				player.Damage = baseDamage * EmotionDamageMult
			end
		elseif flag == CacheFlag.CACHE_FIREDELAY then
			local TearsEmotion = OmoriMod.SwitchCase(currentEmotion, tables.TearsAlterEmotions)
			
			if not TearsEmotion then return end
			
			local tearsMult = TearsEmotion.tearsMult
			local birthrightMult = TearsEmotion.birthrightMult
		
			if OmoriMod:IsOmori(player, false) then
				local birthrightMultiplier = hasBirthright and birthrightMult or 1
				player.MaxFireDelay = OmoriMod.tearsUp(player.MaxFireDelay, tearsMult * birthrightMultiplier, true)
			else
				player.MaxFireDelay = OmoriMod.tearsUp(player.MaxFireDelay, tearsMult, true)
			end	
		elseif flag == CacheFlag.CACHE_SPEED then
			local SpeedEmotion = OmoriMod.SwitchCase(currentEmotion, tables.SpeedAlterEmotions)
			
			if not SpeedEmotion then return end
			
			local speedMult = SpeedEmotion.speedMult
			local birthrightMult = SpeedEmotion.birthrightMult
			
			if OmoriMod:IsOmori(player, false) then
				local birthrightMultiplier = hasBirthright and birthrightMult or 1
				player.MoveSpeed = (player.MoveSpeed * speedMult) * birthrightMultiplier
			else
				player.MoveSpeed = (player.MoveSpeed * speedMult)
			end	
		elseif flag == CacheFlag.CACHE_LUCK then
			local LuckAdded = OmoriMod.SwitchCase(currentEmotion, tables.LuckAlterEmotions)
			local birthrightAdd = (OmoriMod:IsOmori(player, false) and hasBirthright and 1) or 0
			
			if not LuckAdded then return end
			
			player.Luck = player.Luck + (LuckAdded + birthrightAdd)
		end
	else
		if currentEmotion == "Afraid" then
			if flag == CacheFlag.CACHE_DAMAGE then	
				player.Damage = player.Damage * 0.85
			elseif flag == CacheFlag.CACHE_FIREDELAY then	
				player.MaxFireDelay = OmoriMod.tearsUp(player.MaxFireDelay, 0.70, true)
			elseif flag == CacheFlag.CACHE_RANGE then
				player.TearRange = OmoriMod.rangeUp(player.TearRange, -1)
			elseif flag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed * 0.8
			end
		elseif currentEmotion == "StressedOut" then
			if flag == CacheFlag.CACHE_DAMAGE then	
				player.Damage = player.Damage * 0.75
			elseif flag == CacheFlag.CACHE_FIREDELAY then	
				player.MaxFireDelay = OmoriMod.tearsUp(player.MaxFireDelay, 0.65, true)
			elseif flag == CacheFlag.CACHE_RANGE then
				player.TearRange = OmoriMod.rangeUp(player.TearRange, -2)
			elseif flag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed * 0.7
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.OmoStats)
