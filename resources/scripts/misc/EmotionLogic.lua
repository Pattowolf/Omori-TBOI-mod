local mod = OmoriMod
local modrng = RNG()
local game = Game()
local sfx = SFXManager()

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
	
	OmoriMod:OmoriChangeEmotionEffect(player)
	
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

function mod:OverrideLaserdamage(laser, collider)
	local player = OmoriMod.GetPlayerFromAttack(laser)
	if player then	
		local critChance = 0
		local failChance = 0
		local birthrightDamageMult = 1
		local birthrightVelMult = 1
		local newDamage = laser.CollisionDamage
		
		if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			birthrightDamageMult = 1.25
			birthrightVelMult = 1.15
		end
		
		local happyTier = {
			["Happy"] = function()
				critChance = 25
				failChance = 10
			end,
			["Ecstatic"] = function()
				critChance = 38
				failChance = 15
			end,
			["Manic"] = function()
				critChance = 50
				failChance = 30
			end,
		}
		OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), happyTier)
		
		if collider:IsActiveEnemy() and collider:IsVulnerableEnemy() then
			local happyLaserChance = OmoriMod.randomNumber(1, 100, modrng)
			local failLaserChance = OmoriMod.randomNumber(1, 100, modrng)
			local CeiledCritChance = math.ceil(critChance * birthrightDamageMult)
			
			if happyLaserChance <= CeiledCritChance and CeiledCritChance > 0 then
				newDamage = (newDamage * 2) * birthrightDamageMult
			else
				if failLaserChance <= failChance then
					if newDamage == laser.CollisionDamage then
						newDamage = 0
					end
				end
			end
			collider:TakeDamage(newDamage, DamageFlag.DAMAGE_LASER, EntityRef(laser), 0)
			return true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, mod.OverrideLaserdamage)

function mod:OnShootHappyTear(tear)
	OmoriMod.DoHappyTear(tear)
	
	local player = OmoriMod.GetPlayerFromAttack(tear)
	
	-- print(player:FireKnife(tear, 0, false, 1, 11).Variant)
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.OnShootHappyTear)
-- Happy tears Manager end

-- Stats Manager
function mod:OmoStats(player, flag)
	if player:GetPlayerType() ~= OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
		if flag == CacheFlag.CACHE_DAMAGE then
			local EmotionDamageMult = 1
			local damageMult = 1
			local birthrightMult = 1
			
			local emotion = {
				["Sad"] = function()
					EmotionDamageMult = 0.75
					damageMult = 1
					birthrightMult = 0.9
				end,
				["Depressed"] = function()
					EmotionDamageMult = 0.625
					damageMult = 1
					birthrightMult = 0.9
				end,
				["Miserable"] = function()
					EmotionDamageMult = 0.5
					damageMult = 1
					birthrightMult = 0.9
				end,
				["Angry"] = function()
					EmotionDamageMult = 1.3
					damageMult = 1.2
					birthrightMult = 1.15
				end,
				["Enraged"] = function()
					EmotionDamageMult = 1.6
					damageMult = 1.2
					birthrightMult = 1.15
				end,
				["Furious"] = function()
					EmotionDamageMult = 2
					damageMult = 1.2
					birthrightMult = 1.15
				end,
			}
			OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), emotion)

			if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
					birthrightMult = 1
				end
				player.Damage = (((player.Damage * damageMult) * EmotionDamageMult) * 0.8) * birthrightMult
			else
				player.Damage = ((player.Damage * EmotionDamageMult))
			end
			
		elseif flag == CacheFlag.CACHE_FIREDELAY then
			local tearsMult = 1
			local birthrightMult = 1
		
			local emotion = {
				["Sad"] = function()
					tearsMult = 1.3
					birthrightMult = 1.2
				end,
				["Depressed"] = function()
					tearsMult = 1.4
					birthrightMult = 1.2
				end,
				["Miserable"] = function()
					tearsMult = 1.5
					birthrightMult = 1.2
				end,
				["Angry"] = function()
					tearsMult = 0.8
					birthrightMult = 0.9
				end,
				["Enraged"] = function()
					tearsMult = 0.75
					birthrightMult = 0.9
				end,
				["Furious"] = function()
					tearsMult = 0.65
					birthrightMult = 0.9
				end,
			}
		
			OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), emotion)
					
			if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
					birthrightMult = 1
				end
				
				player.MaxFireDelay = OmoriMod.tearsUp(player.MaxFireDelay, tearsMult * birthrightMult, true)
			else
				player.MaxFireDelay = OmoriMod.tearsUp(player.MaxFireDelay, tearsMult, true)
			end
		elseif flag == CacheFlag.CACHE_SPEED then
			local speedMult = 1
			local birthrightMult = 1
		
			local emotion = { 
				["Happy"] = function()
					speedMult = 1.25
					birthrightMult = 1.1
				end,
				["Ecstatic"] = function()
					speedMult = 1.375
					birthrightMult = 1.1
				end,
				["Manic"] = function()
					speedMult = 1.5
					birthrightMult = 1.1
				end,
				["Sad"] = function()
					speedMult = 0.8
					birthrightMult = 0.9
				end,
				["Depressed"] = function()
					speedMult = 0.7
					birthrightMult = 0.9
				end,
				["Miserable"] = function()
					speedMult = 0.6
					birthrightMult = 0.9
				end,
			}
			OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), emotion)
			
			if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
					birthrightMult = 1
				end
				player.MoveSpeed = (player.MoveSpeed * speedMult) * birthrightMult
			else
				player.MoveSpeed = (player.MoveSpeed * speedMult)
			end
		elseif flag == CacheFlag.CACHE_LUCK then
			local luckAdded = 0
			local birthrightAdd = 0
			
			local emotion = {
				["Happy"] = function()
					luckAdded = 1
					birthrightAdd = 1
				end,
				["Ecstatic"] = function()
					luckAdded = 2
					birthrightAdd = 1
				end,
				["Manic"] = function()
					luckAdded = 3
					birthrightAdd = 1
				end,
			}
			OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), emotion)
			
			if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
					birthrightAdd = 0
				end
				player.Luck = (player.Luck + luckAdded) + birthrightAdd
			else
				player.Luck = (player.Luck + luckAdded) 
			end
		end
	else
		if OmoriMod.GetEmotion(player) == "Afraid" then
			if flag == CacheFlag.CACHE_DAMAGE then	
				player.Damage = player.Damage * 0.85
			elseif flag == CacheFlag.CACHE_FIREDELAY then	
				player.MaxFireDelay = OmoriMod.tearsUp(player.MaxFireDelay, 0.70, true)
			elseif flag == CacheFlag.CACHE_RANGE then
				player.TearRange = OmoriMod.rangeUp(player.TearRange, -1)
			elseif flag == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed * 0.8
			end
		elseif OmoriMod.GetEmotion(player) == "StressedOut" then
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
