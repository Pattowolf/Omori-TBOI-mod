local mod = OmoriMod
local enums = OmoriMod.Enums
local tables = enums.Tables
local utils = enums.Utils
local sfx = utils.SFX
local rng = utils.RNG
local game = utils.Game
local OmoriModCallbacks = enums.Callbacks
local misc = enums.Misc
local sounds = enums.SoundEffect
local debug = false

---@param player EntityPlayer
---@return number
local function getWeaponDMG(player)
    local playerData = OmoriMod:GetData(player)
	local emotion = OmoriMod.GetEmotion(player)
    local DamageMult = (OmoriMod:IsOmori(player, true) and 2) or (OmoriMod:IsOmori(player, false) and 2.5) or 3
	
	local angerValues = {
		["Angry"] = 1.1,
		["Enraged"] = 1.2,
		["Furious"] = 1.3,
	}

	local SunnyEmotionsMult = {
		["Neutral"] = 0,
		["Afraid"] = 1,
		["StressedOut"] = 2
	}
	
	local AngerMult = angerValues[emotion] or 1

    if OmoriMod:IsOmori(player, true) then
		local isFocus = playerData.IncreasedBowDamage
		local FocusBonus = isFocus == true and 1 or 0
		local SunnyMult = SunnyEmotionsMult[emotion]

		DamageMult = DamageMult + SunnyMult + FocusBonus
    end
    return (player.Damage * DamageMult) * AngerMult
end

local function HasVeganMilk(player)
	return (player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK))
end

function mod:RenderShinyKnifeCharge()
	local players = PlayerManager.GetPlayers()
	local room = game:GetRoom()

	for _, player in ipairs(players) do

		if HasVeganMilk(player) then return end

		local playerData = OmoriMod:GetData(player)
		local isShooting = OmoriMod:IsPlayerShooting(player)
		local chargeBar = playerData.shinyKnifeChargeBar

		local update = true

		if not chargeBar then
			playerData.shinyKnifeChargeBar = Sprite()
			playerData.shinyKnifeChargeBar:Load("gfx/chargebar.anm2", true)
		else
			if not playerData.shinyKnifeCharge or playerData.shinyKnifeCharge == 0 then return end
			chargeBar.PlaybackSpeed = 0.5
			if not chargeBar:IsPlaying("Disappear") and playerData.shinyKnifeCharge ~= 0 and isShooting then
				if playerData.shinyKnifeCharge < 100 and (chargeBar:GetAnimation() ~= "Charged") then
					chargeBar:SetFrame("Charging", math.ceil(playerData.shinyKnifeCharge))
					update = false
				else
					if chargeBar:GetAnimation() == "Charging" then		
						chargeBar:Play("StartCharged", true)
					elseif chargeBar:IsFinished("StartCharged") and not (chargeBar:GetAnimation() == "Charged") then
						chargeBar:Play("Charged", true)
					end
				end
			else
				chargeBar:Play("Disappear")
			end
		end		
		playerData.shinyKnifeChargeBar.Offset = Vector(0, 10)
		playerData.shinyKnifeChargeBar:Render(room:WorldToScreenPosition(player.Position), Vector.Zero, Vector.Zero)
			
		if update then
			playerData.shinyKnifeChargeBar:Update()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.RenderShinyKnifeCharge)

function mod:OnKnifeRemoving()
	local players = PlayerManager.GetPlayers()
	for _, player in ipairs(players) do
		local playerData = OmoriMod:GetData(player)
		playerData.ShinyKnife = nil
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.OnKnifeRemoving)

function mod:KnifeSmoothRotation(player)
	local playerData = OmoriMod:GetData(player)

	if not playerData.ShinyKnife then return end

	local knife = playerData.ShinyKnife
	local knifesprite = knife:GetSprite()
	local knifeData = OmoriMod:GetData(knife)
	local isShooting = OmoriMod:IsPlayerShooting(player)
	local aimDegrees = player:GetAimDirection():GetAngleDegrees() 
	local isIdle = knifesprite:IsPlaying("Idle")
	local isMoving = OmoriMod:IsPlayerMoving(player)

	knife.Position = player.Position

	if isShooting then
		knifeData.Aiming = aimDegrees
	end

	local headDir = player:GetHeadDirection()
	local renderBelowPlayer = headDir == 0 or headDir == 1

	knife.DepthOffset = (renderBelowPlayer and -10) or 10

	if isShooting then
		knife.SpriteRotation = knifeData.Aiming
	else
		if isIdle then
			knife.SpriteRotation = player:GetSmoothBodyRotation()
			if not isMoving then
				knife.SpriteRotation = tables.DirectionToDegrees[player:GetHeadDirection()]
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.KnifeSmoothRotation)

---comment
---@param knife EntityEffect
function mod:ShinyKnifeUpdate(knife)
	local knifesprite = knife:GetSprite()
    local player = knife.SpawnerEntity:ToPlayer()

	local Ret = Isaac.RunCallback(OmoriModCallbacks.PRE_KNIFE_UPDATE, knife)

	if Ret == false then return end
    local knifeData = OmoriMod:GetData(knife)

	if not player then return end
    local playerData = OmoriMod:GetData(player)
	
	local isShooting = OmoriMod:IsPlayerShooting(player)	
	local multiShot = player:GetMultiShotParams(WeaponType.WEAPON_TEARS)
	local numTears = multiShot:GetNumTears()
	local isIdle = knifesprite:IsPlaying("Idle")
	local baseSwings = OmoriMod:IsOmori(player, true) and 2 or 0
	local frame = knifesprite:GetFrame()
	local HasMarked = player:GetMarkedTarget() ~= nil

	playerData.shinyKnifeCharge = playerData.shinyKnifeCharge or 0
	playerData.Swings = playerData.Swings or 0
			
	if isShooting then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) and isIdle then
			knifeData.HitBlacklist = {}
			OmoriMod:InitKnifeSwing(knife)	
		end

		if isIdle then
			local knifeChargeFormula = (OmoriMod:IsOmori(player, true) and (((0.05 + (OmoriMod.TearsPerSecond(player) / 50)) / 2.5)) * 100) or (((0.025 + (OmoriMod.TearsPerSecond(player) / 100)) / 2.5)) * 100
			
			local newCharge = Isaac.RunCallback(OmoriModCallbacks.PRE_KNIFE_CHARGE, knife)

			if newCharge then
				knifeChargeFormula = newCharge
			end

			playerData.shinyKnifeCharge = math.min(playerData.shinyKnifeCharge + knifeChargeFormula, 100)
			
			if playerData.shinyKnifeCharge >= 99 then playerData.shinyKnifeCharge = 100 end

			playerData.Swings = numTears + baseSwings		
			
			if HasMarked and playerData.shinyKnifeCharge == 100 and playerData.Swings > 0 and isIdle then
				OmoriMod:InitKnifeSwing(knife)
				playerData.Swings = playerData.Swings - 1
			end
		end
	else
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) and playerData.shinyKnifeCharge ~= 0 then
			OmoriMod:InitKnifeSwing(knife)
		end

		if playerData.shinyKnifeCharge == 100 and playerData.Swings > 0 and isIdle then
			OmoriMod:InitKnifeSwing(knife)
			playerData.Swings = playerData.Swings - 1
		end 
	
		if playerData.shinyKnifeCharge ~= 100 then
			playerData.shinyKnifeCharge = 0
		end
	end

	if knifesprite:IsPlaying("Swing") then
		if frame == math.floor(knifesprite.PlaybackSpeed) then
			Isaac.RunCallback(OmoriModCallbacks.KNIFE_SWING_TRIGGER, knife)
		end
		Isaac.RunCallback(OmoriModCallbacks.KNIFE_SWING, knife)
	end

	if knifesprite:IsFinished("Swing") then
		knifeData.HitBlacklist = {}
		knifesprite:Play("Idle")
		
		Isaac.RunCallback(OmoriModCallbacks.KNIFE_SWING_FINISH, knife)

		if playerData.Swings == 0 and knifesprite:IsPlaying("Idle") then
			playerData.shinyKnifeCharge = 0
		elseif playerData.Swings > 0 and knifesprite:IsPlaying("Idle") and isShooting and not knifeData.SwordSwing then
			OmoriMod:InitKnifeSwing(knife)
			playerData.Swings = playerData.Swings - 1
		end
		knifeData.IsCriticAtack = false
		knife.Color = Color.Default

		if knifeData.SwordSwing then
			knifeData.SwordSwing = false
		end

		playerData.ChoccyCharge = 0

		OmoriMod:SetKnifeSizeMult(knife, 1)
	end	

	local swingSpeed = knifeData.SwordSwing and 2.5 or ((numTears > 1 and 1.5) or 1)

	knifesprite.PlaybackSpeed = swingSpeed

	Isaac.RunCallback(OmoriModCallbacks.POST_KNIFE_UPDATE, knife)
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.ShinyKnifeUpdate, OmoriMod.Enums.EffectVariant.EFFECT_SHINY_KNIFE)

---@param knife EntityEffect
function mod:OnKnifeSwingTrigger(knife)
	local knifeData = OmoriMod:GetData(knife)
	local CriticDamageChance = OmoriMod.randomNumber(1, 100, rng) 

	local player = knife.SpawnerEntity:ToPlayer()
	
	if not player then return end
	
	if not (OmoriMod:IsAnyOmori(player) or player:HasCollectible(enums.CollectibleType.COLLECTIBLE_SHINY_KNIFE)) then return end

	local soundEffect = (OmoriMod:IsOmori(player, true) and sounds.SOUND_VIOLIN_BOW_SLASH) or sounds.SOUND_BLADE_SLASH

	local randomPitch = soundEffect == sounds.SOUND_VIOLIN_BOW_SLASH and OmoriMod.randomfloat(0.9, 1.1, rng) or 1

	sfx:Play(soundEffect, 1, 0, false, randomPitch, 0)

	if not player then return end

	local emotion = OmoriMod.GetEmotion(player)

	knifeData.IsCriticAtack = knifeData.IsCriticAtack or false

	if tables.HappinessTiers[emotion] == nil then return end
		
	local criticChance = tables.HappyKnifeCriticChance[emotion]
				
	if CriticDamageChance <= criticChance then
		knifeData.IsCriticAtack = true
		knife.Color = misc.CriticColor
	else
		knifeData.IsCriticAtack = false
	end
end
mod:AddCallback(OmoriModCallbacks.KNIFE_SWING_TRIGGER, mod.OnKnifeSwingTrigger)

if debug == true then 
	function mod:AAAA(knife)	
		for i = 1, 2 do
			local capsule = knife:GetNullCapsule("KnifeHit" .. 2)
			local debugShape = knife:GetDebugShape()
			debugShape:Capsule(capsule)
		end
	end
	mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.AAAA, enums.EffectVariant.EFFECT_SHINY_KNIFE)
end

function mod:OnKnifeSwing(knife)
	local knifeData = OmoriMod:GetData(knife)
	knifeData.HitBlacklist = knifeData.HitBlacklist or {}		
	knife.SpriteRotation = knifeData.Aiming
		
	local player = OmoriMod:GetKnifeOwner(knife)

	OmoriMod:SetKnifeSizeMult(knife, math.max((player.TearRange / 40) / 6.5, 1))

	for i = 1, 2 do
		local capsule = knife:GetNullCapsule("KnifeHit" .. i)
		for _, entity in ipairs(Isaac.FindInCapsule(capsule)) do
			if entity:ToPlayer() or entity:ToTear() then return end
			if not knifeData.HitBlacklist[GetPtrHash(entity)] then
				local isEnemy = entity:IsVulnerableEnemy() and entity:IsActiveEnemy()
				if isEnemy then
					knifeData.Damage = getWeaponDMG(player)

					local hasKnife = player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
					local numberHits = hasKnife and 4 or 1

					for _ =1, numberHits do
						Isaac.RunCallback(OmoriModCallbacks.KNIFE_HIT_ENEMY, knife, entity, knifeData.Damage)
						entity:TakeDamage(knifeData.Damage, 0, EntityRef(knife), 0)
					end

					if entity.HitPoints <= knifeData.Damage then
						Isaac.RunCallback(OmoriModCallbacks.KNIFE_KILL_ENEMY, knife, entity)
					end
				else
					Isaac.RunCallback(OmoriModCallbacks.KNIFE_ENTITY_COLLISION, knife, entity)	
				end
				knifeData.HitBlacklist[GetPtrHash(entity)] = true
			end
		end
	end
end
mod:AddCallback(OmoriModCallbacks.KNIFE_SWING, mod.OnKnifeSwing)

---comment
---@param knife EntityEffect
---@param entity Entity
---@param damage number
---@return number?
function mod:OnDamagingWithShinyKnife(knife, entity, damage)
	local player = knife.SpawnerEntity:ToPlayer()
	local knifeData = OmoriMod:GetData(knife)

	if not player then return end

	if not (OmoriMod:IsAnyOmori(player) or player:HasCollectible(enums.CollectibleType.COLLECTIBLE_SHINY_KNIFE)) then return end

	local emotion = OmoriMod.GetEmotion(player)
	local IsHappy = tables.HappinessTiers[emotion]
	
	local Damage = damage

	if IsHappy then
		if knifeData.IsCriticAtack then
			Damage = Damage * 2
			sfx:Play(OmoriMod.Enums.SoundEffect.SOUND_RIGHT_IN_THE_HEART, 1, 0, false, 1, 0)
		else
			local failChance = tables.HappinessFailChance[emotion] 
			if failChance then
				local failTriggerChance = OmoriMod.randomNumber(1, 100, rng)
				if failTriggerChance <= failChance then	
					sfx:Play(OmoriMod.Enums.SoundEffect.SOUND_MISS_ATTACK, 1, 0, false, 1, 0)
					Damage = 0
				end
			end
		end
	end
	
	if Damage > 0 then 
		sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1, 0)
	end
	
	local birthrightMult = (OmoriMod:IsOmori(player, false) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 1.2) or 1
	
	local sadKnockbackMult = (tables.SadnessKnockbackMult[emotion] or 1) * (birthrightMult or 1)
		
	local resizer = (20 * sadKnockbackMult) * (player.ShotSpeed)
	entity:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK | EntityFlag.FLAG_APPLY_IMPACT_DAMAGE)
	entity.Velocity = (entity.Position - player.Position):Resized(resizer) 
end
mod:AddCallback(OmoriModCallbacks.KNIFE_HIT_ENEMY, mod.OnDamagingWithShinyKnife)

function mod:KnifeRenderMan(knife)
	Isaac.RunCallback(OmoriModCallbacks.POST_KNIFE_RENDER, knife)
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, mod.KnifeRenderMan, enums.EffectVariant.EFFECT_SHINY_KNIFE)

function mod:ShinyKnifeKill(knife, enemy)
	local knifeData = OmoriMod:GetData(knife)
	local player = knife.SpawnerEntity:ToPlayer()
	local emotion = OmoriMod.GetEmotion(player)
	if not knifeData.IsCriticAtack then return end

	local happyTier = {
		["Happy"] = 10,
		["Ecstatic"] = 15,
		["Manic"] = 20,
	} 

	local SpawnPickupChance = OmoriMod.randomNumber(1, 100, rng)
	local MaxSpawnPickupChance = happyTier[emotion]

	if not MaxSpawnPickupChance then return end

	if SpawnPickupChance <= MaxSpawnPickupChance + (player.Luck) then
		local PickupSpawn = {
			[1] = PickupVariant.PICKUP_HEART,
			[2] = PickupVariant.PICKUP_COIN,
			[3] = PickupVariant.PICKUP_KEY,
			[4] = PickupVariant.PICKUP_BOMB
		}

		local pickupToSpawn = PickupSpawn[OmoriMod.randomNumber(1, 4, rng)]

		Isaac.Spawn(
			EntityType.ENTITY_PICKUP,
			pickupToSpawn,
			0,
			enemy.Position,
			Vector.Zero,
			nil
		)
	end
end
mod:AddCallback(OmoriModCallbacks.KNIFE_KILL_ENEMY, mod.ShinyKnifeKill)

---comment
---@param knife EntityEffect
---@param entity Entity
function mod:KnifeCollidingNonEnemies(knife, entity)
	local player = OmoriMod:GetKnifeOwner(knife)
	local playerData = OmoriMod:GetData(player)

	local NonEnemyEntities = {
		[EntityType.ENTITY_FAMILIAR] = function()
			if entity.Variant == FamiliarVariant.PUNCHING_BAG or entity.Variant == FamiliarVariant.CUBE_BABY then
				OmoriMod:TriggerPush(entity, player, 30)
			end
		end,
		[EntityType.ENTITY_BOMB] = function()
			OmoriMod:TriggerPush(entity, player, 30)
		end,
		[EntityType.ENTITY_FIREPLACE] = function()
			local BlacklistedFireplaces = {
				[2] = true,
				[3] = true,
				[4] = true,
				[12] = true,
				[13] = true,
			}
			local isBlacklistedFireplace = BlacklistedFireplaces[entity.Variant] or false

			if isBlacklistedFireplace == false then
				entity:Kill()
			end
		end,
		[EntityType.ENTITY_PICKUP] = function()
			local pickupBlackList = {
				[PickupVariant.PICKUP_COLLECTIBLE] = true,
				[PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
				[PickupVariant.PICKUP_TROPHY] = true,
				[PickupVariant.PICKUP_BED] = true,
				[PickupVariant.PICKUP_MOMSCHEST] = true,
			}
			local isBlackListedPickup = pickupBlackList[entity.Variant] or false

			if isBlackListedPickup == false then
				player:ForceCollide(entity, true)
			end
		end,
		[EntityType.ENTITY_PROJECTILE] = function()
			local projectile = entity:ToProjectile()
			if not projectile then return end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
				if playerData.shinyKnifeCharge >= 100 then
					projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES | ProjectileFlags.CANT_HIT_PLAYER)
					projectile.Damage = player.Damage * 2
					OmoriMod:TriggerPush(entity, player, 20)
				end
			end

			if player:HasCollectible(CollectibleType.COLLECTIBLE_LOST_CONTACT) then
				projectile:Kill()
			end
		end,
		[EntityType.ENTITY_STONEY] = function()
			OmoriMod:TriggerPush(entity, player, 30)
		end,
	}

	if not NonEnemyEntities[entity.Type] then return end
	OmoriMod.When(entity.Type, NonEnemyEntities, 2)()
end
mod:AddCallback(OmoriModCallbacks.KNIFE_ENTITY_COLLISION, mod.KnifeCollidingNonEnemies)

function mod:tearsAdjustment(player, flag)
    if OmoriMod:IsKnifeUser(player) then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) and (player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) or player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)) then
            if flag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = OmoriMod.tearsUp(player.MaxFireDelay, 1 / 3, true)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.tearsAdjustment)