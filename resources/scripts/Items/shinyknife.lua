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
	return (player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK))
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

	playerData.shinyKnifeCharge = playerData.shinyKnifeCharge or 0
	playerData.Swings = playerData.Swings or 0
	
	local HasMarked = player:GetMarkedTarget() ~= nil
		
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

					for _ = 1, numberHits do
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
function mod:KnifeColliding(knife, entity)
	local familiar = entity:ToFamiliar()
	
	if not familiar then return end
	
	if familiar.Variant ~= FamiliarVariant.CUBE_BABY then return end
	
	entity.Velocity = (entity.Position - knife.Position):Resized(20) 
end
mod:AddCallback(OmoriModCallbacks.KNIFE_ENTITY_COLLISION, mod.KnifeColliding)

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

-- function ShinyKnife:KnifeEffectUpdate(knife)
    -- local knifesprite = knife:GetSprite()
    -- local player = knife.SpawnerEntity:ToPlayer()
    -- local data = OmoriMod:GetData(knife)
    -- local playerData = OmoriMod:GetData(player)
	-- local room = Game():GetRoom() 

	-- if not playerData.ExtraSwings then
		-- if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
			-- playerData.ExtraSwings = 3
		-- else
			-- playerData.ExtraSwings = 0
		-- end
    -- end
	
	-- playerData.shinyKnifeCharge = playerData.shinyKnifeCharge or 0
	-- playerData.SwordSwing = playerData.SwordSwing or false
	-- playerData.ChocolateDmgMult = playerData.ChocolateDmgMult or 0	
	-- playerData.Aiming = playerData.Aiming or Vector.Zero
	-- data.HappyAttack = data.HappyAttack or false

    -- local shoot = {
        -- l = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
        -- r = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
        -- u = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
        -- d = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
    -- }

    -- local isShooting = (shoot.l or shoot.r or shoot.u or shoot.d)
	
    -- local chocolateChargeMult = 1

    -- if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
        -- chocolateChargeMult = 0.7
    -- end

	-- local sadTier = {
		-- ["Sad"] = 1.1,
		-- ["Depressed"] = 1.2,
		-- ["Miserable"] = 1.3,
	-- }
	
	-- local sadMultiplier = OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), sadTier) or 1

	-- local PitchVariation = OmoriMod.randomfloat(0.95, 1.05, rng)
    -- local volume = 1.3
    -- local sound = OmoriMod.Enums.SoundEffect.SOUND_BLADE_SLASH
    -- local knifeChargeFormula = (((0.01 + (OmoriMod.TearsPerSecond(player) / 100)) / 3.5) * chocolateChargeMult) * sadMultiplier
	
    -- if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
		-- PitchVariation = OmoriMod.randomfloat(0.8, 1.05, rng)
        -- volume = 3
        -- sound = OmoriMod.Enums.SoundEffect.SOUND_VIOLIN_BOW_SLASH
        -- knifeChargeFormula = ((0.015 + (OmoriMod.TearsPerSecond(player) / 100)) / 2.25) * chocolateChargeMult
    -- end
	
	-- if player:GetHeadDirection() == 0 or player:GetHeadDirection() == 1 or knifesprite:IsPlaying("Swing") or player:IsHoldingItem() == true then
        -- knife.DepthOffset = -10
    -- else
        -- knife.DepthOffset = 1
    -- end
	
    -- if isShooting == true then
        -- if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then
            -- knifesprite:Play("Swing")
            -- knifesprite.PlaybackSpeed = math.max(OmoriMod.TearsPerSecond(player) / 10, 1)
        -- end
		-- if player:IsHoldingItem() == false then
			-- if not knifesprite:IsPlaying("Swing") then
				-- playerData.shinyKnifeCharge = math.min(playerData.shinyKnifeCharge + (knifeChargeFormula * 2), 1)
			-- end
		-- end
		-- playerData.HeadDirection = player:GetHeadDirection()
	-- else
        -- if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
            -- if playerData.shinyKnifeCharge > 0 then
                -- local forceHeadTime = math.ceil(10 * playerData.shinyKnifeCharge) + 1
				-- knifesprite:Play("Swing")
				-- OmoriMod:ForceHeadDirLudo(player, forceHeadTime)
                -- if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) and playerData.shinyKnifeCharge >= 1 then
                    -- playerData.SwordSwing = true
                -- end
                -- knifesprite.PlaybackSpeed = (1 / (playerData.shinyKnifeCharge + 0.30))
            -- end
        -- end
        -- if playerData.shinyKnifeCharge >= 1 then
            -- knifesprite:Play("Swing")
			
			-- OmoriMod:ForceHeadDirLudo(player, 10)
			
			-- knifesprite.PlaybackSpeed = 1
			-- if playerData.ExtraSwings > 0 then
				-- knifesprite.PlaybackSpeed = 1.5
			-- end
        -- end
        -- playerData.shinyKnifeCharge = 0
    -- end

    -- if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
        -- if playerData.shinyKnifeCharge ~= 0 then
            -- playerData.ChocolateDmgMult = math.min(playerData.shinyKnifeCharge, 1)
        -- end
    -- end

    -- if knifesprite:IsFinished("Swing") then
        -- data.HitBlacklist = {}
        -- knifesprite:Play("Idle")
		
        -- if playerData.ExtraSwings == 0 then
		
			-- if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
				-- playerData.ExtraSwings = playerData.ExtraSwings + 2
			-- end
			-- if player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) then
				-- playerData.ExtraSwings = playerData.ExtraSwings + 3
			-- end
			-- if player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) then
				-- playerData.ExtraSwings = playerData.ExtraSwings + 4
			-- end
			
			-- if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
				-- playerData.ExtraSwings = playerData.ExtraSwings + 3
			-- end
        -- end

        -- if playerData.ExtraSwings > 0 then
            -- playerData.ExtraSwings = playerData.ExtraSwings - 1
            -- knifesprite:Play("Swing")
			-- knifesprite.PlaybackSpeed = 1.5
        -- end

        -- if playerData.ExtraSwings == 0 then
            -- knifesprite:Play("Idle")
			-- if playerData.SwordSwing == true then
				-- playerData.SwordSwing = false
			-- end
			-- if playerData.ChocolateDmgMult > 0 then
				-- playerData.ChocolateDmgMult = 0
			-- end
			-- if playerData.IncreasedBowDamage == true then
				-- playerData.IncreasedBowDamage = false
			-- end
        -- end
		
        -- knife.Color = Color.Default
		
        -- if data.HappyAttack == true then
            -- data.HappyAttack = false
        -- end
    -- end

    -- local triggerShoot = {
        -- l = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
        -- r = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
        -- u = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
        -- d = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
    -- }
    -- local isTriggerShoot = (triggerShoot.l or triggerShoot.r or triggerShoot.u or triggerShoot.d)

    -- if isTriggerShoot then
        -- if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) or  player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
            -- data.HitBlacklist = {}
            -- knifesprite.Rotation = DIRECTION_TO_DEGREES[player:GetHeadDirection()]
        -- end
    -- end

	-- OmoriMod:replaceKnifeSprite(player, knife)
	
	-- if isShooting then
		-- playerData.Aiming = getAimDirection(player)
	-- else
		-- playerData.Aiming = playerData.Aiming
	-- end
	
	-- if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then
        -- knifesprite.Rotation = DIRECTION_TO_DEGREES[player:GetHeadDirection()]
    -- else
        -- if knifesprite:IsPlaying("Swing") then
            -- if player:CanTurnHead() == true then
                -- if playerData.ExtraSwings > 0 then
					-- knifesprite.Rotation = DIRECTION_TO_DEGREES[player:GetHeadDirection()]
					-- if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
						-- knifesprite.Rotation = DIRECTION_TO_DEGREES[player:GetHeadDirection()]
					-- else
						-- knifesprite.Rotation = knifesprite.Rotation
					-- end
                -- else
					-- if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
						-- knifesprite.Rotation = DIRECTION_TO_DEGREES[player:GetHeadDirection()]
					-- else
						-- knifesprite.Rotation = knifesprite.Rotation
					-- end
                -- end
            -- else
                -- knifesprite.Rotation = DIRECTION_TO_DEGREES[player:GetHeadDirection()]
            -- end
        -- elseif knifesprite:IsPlaying("Idle") then
            -- knifesprite.Rotation = DIRECTION_TO_DEGREES[player:GetHeadDirection()]
            -- data.HitBlacklist = {}
        -- end
    -- end
	
	-- knife.SpriteScale = Vector.One * math.max(player.SpriteScale.X, 1)
	-- local sunnyIncreaserSize = 1
	
	-- if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI_B then
		-- if OmoriMod.GetEmotion(player) == "Afraid" then
			-- sunnyIncreaserSize = 1.15
		-- elseif OmoriMod.GetEmotion(player) == "StressedOut" then
			-- sunnyIncreaserSize = 1.2
		-- end
	-- end

    -- if knifesprite:IsPlaying("Swing") then
		-- knife.SpriteScale = ((knife.SpriteScale * (((player.TearRange / 40) - 6.5) / 40) + Vector.One) * player.SpriteScale.X * sunnyIncreaserSize) 
			
		-- if playerData.SwordSwing then
			-- knife.SpriteScale = knife.SpriteScale * 1.3
		-- end
		
        -- if knifesprite:GetFrame() == 0 then
			-- local randomRed = OmoriMod.randomfloat(0, 1, rng)
			-- local randomGreen = OmoriMod.randomfloat(0, 1, rng)
			-- local randomBlue = OmoriMod.randomfloat(0, 1, rng)
		
			-- if player:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE) then
				-- knifesprite.Color = Color(randomRed, randomGreen, randomBlue, 1, 0, 0, 0)
			-- end
		
            -- sfx:Play(sound, volume, 0, false, PitchVariation, 0)
            -- data.CriticKnifeDamageChance = OmoriMod.randomNumber(1, 100, rng)

			-- local SpecialInteractions = {
				-- [CollectibleType.COLLECTIBLE_TECH_X] = function()
					-- local techX =
                    -- player:FireTechXLaser(
						-- knife.Position + playerData.Aiming:Resized(30 * knife.SpriteScale.X),
						-- Vector.Zero,
						-- 30 * knife.SpriteScale.X,
						-- player,
						-- 1
					-- ):ToLaser()
					-- techX:AddTearFlags(player.TearFlags)
					-- techX:SetTimeout(8)
				-- end,	
				-- [CollectibleType.COLLECTIBLE_BRIMSTONE] = function()
					-- local brimRing =
						-- player:FireBrimstoneBall(
						-- knife.Position + playerData.Aiming:Resized(30 * knife.SpriteScale.X),
						-- playerData.Aiming:Resized(30 * knife.SpriteScale.X) / 10,
						-- Vector.Zero
					-- )
				-- end,
				-- [CollectibleType.COLLECTIBLE_GODHEAD] = function()
					-- local GodTear =
                        -- Isaac.Spawn(
                        -- 2,
                        -- 0,
                        -- 0,
                        -- knife.Position + playerData.Aiming:Resized(30 * knife.SpriteScale.X),
                        -- Vector.Zero,
                        -- player
                    -- ):ToTear()
                    -- GodTear.Color = Color(1, 1, 1, 0, 1, 1, 1)
                    -- GodTear.CollisionDamage = 0
                    -- GodTear:AddTearFlags(TearFlags.TEAR_GLOW | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
                    -- GodTear.Scale = knife.SpriteScale.X
                    -- GodTear:GetSprite():ReplaceSpritesheet(0, "")
                    -- GodTear:GetSprite():LoadGraphics()
                    -- GodTear:GetSprite():Update()
                    -- local godTearData = OmoriMod:GetData(GodTear)

                    -- if not godTearData.TaearFromKnife then
                        -- godTearData.TearFromKnife = true
                    -- end
				-- end,
			-- }
			
			-- local CriticKnifeDamageMaxChance = 0
            -- local happyTier = {
                -- ["Happy"] = 25,
                -- ["Ecstatic"] = 40,
                -- ["Manic"] = 60,
            -- }
			-- CriticKnifeDamageMaxChance = OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), happyTier) or 0

			-- if data.CriticKnifeDamageChance + player.Luck <= CriticKnifeDamageMaxChance then
				-- knife.Color = Color(0.8, 0.8, 0.8, 1, 255/255, 200/255, 100/255)
                -- data.HappyAttack = true
			-- end
        -- end
    -- end
   
    -- data.HitBlacklist = data.HitBlacklist or {}

	-- if knifesprite:IsPlaying("Swing") then
		-- for i = 1, 2 do
			-- local capsule = knife:GetNullCapsule("KnifeHit" .. i)
			-- local capsulePosition = capsule:GetPosition()
			
			-- for _, entity in ipairs(Isaac.FindInCapsule(capsule, 0xFFFFFFFF)) do
				-- if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
					-- local dmg = getWeaponDMG(player)
					-- local totalHits = 1
					-- if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
						-- totalHits = 5
					-- end	
					
					-- if not data.HitBlacklist[GetPtrHash(entity)] then
						-- if data.HappyAttack and data.HappyAttack == true then
							-- dmg = dmg * 2
							
							-- local happyTier = {
								-- ["Happy"] = 5,
								-- ["Ecstatic"] = 10,
								-- ["Manic"] = 20,
							-- } 
							
							-- local spawnPickupChance = OmoriMod.randomNumber(1, 100, rng)
							-- local MaxSpawnPickupChance = OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), happyTier)
							
							-- if not entity:IsBoss() then
								-- if entity.HitPoints <= dmg then
									-- if spawnPickupChance <= MaxSpawnPickupChance then
										-- local pickupsToSpawn = {
											-- PickupVariant.PICKUP_HEART,
											-- PickupVariant.PICKUP_COIN,
											-- PickupVariant.PICKUP_KEY,
											-- PickupVariant.PICKUP_BOMB,									
										-- }
										-- local VariantChoice = OmoriMod.randomNumber(1, 4, rng)
										-- Isaac.Spawn(EntityType.ENTITY_PICKUP, pickupsToSpawn[VariantChoice], 0, entity.Position, Vector.Zero, nil)
									-- end
								-- end
							-- end
						-- end
						
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
							-- if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
								-- dmg = dmg * 0.4
							-- else
								-- dmg = dmg * 0.75
							-- end						
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
							-- if playerData.ChocolateDmgMult < 0.15 then
								-- dmg = dmg * (playerData.ChocolateDmgMult * 3) + 0.1
							-- else
								-- dmg = dmg * (playerData.ChocolateDmgMult * 3)
							-- end
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
							-- if playerData.SwordSwing and playerData.SwordSwing == true then
								-- dmg = dmg * 4
								-- if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
									-- dmg = dmg * 0.5
								-- end
							-- else	
								-- dmg = dmg * 1.25
									
								-- if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
									-- dmg = dmg * 0.9
								-- end
							-- end
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) then
							-- local castLightChance = OmoriMod.randomfloat(0, 1, rng)
							-- local maxChance = math.min(1 / (10 - (player.Luck * 0.9)), 0.5)
								
							-- if player.Luck > 11 then	
								-- maxChance = 0.5
							-- end

							-- if castLightChance <= maxChance then
								-- Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 10, entity.Position, Vector.Zero, player)
								-- entity:TakeDamage(dmg * 3, DamageFlag.DAMAGE_LASER, EntityRef(player), 0)
							-- end
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
							-- local jacobs = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CHAIN_LIGHTNING, 0, entity.Position, Vector.Zero, player):ToEffect()
							-- jacobs.CollisionDamage = player.Damage
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_APPLE) then
							-- local AppleChance = OmoriMod.randomfloat(0.01, 1, rng)
							-- local maxChance = math.min(1 / (15 - player.Luck), 1)
							-- if AppleChance <= maxChance then
								-- dmg = dmg * 4
							-- end
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE) then
							-- local ToughLoveChance = OmoriMod.randomNumber(1, 100, rng)
							-- local maxChance = math.min(10 + (player.Luck * 10), 100)
							-- if ToughLoveChance <= maxChance then
								-- dmg = dmg * 3.2
							-- end
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_STYE) then
							-- local StyeChance = OmoriMod.randomNumber(0, 1, rng)
							-- if StyeChance == 1 then
								-- dmg = dmg * 1.28
							-- end
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_OCULAR_RIFT) then
							-- local SpawnRiftChance = OmoriMod.randomNumber(1, 100, rng)
							-- local maxChance = math.min(math.min(1 / (20 - (math.min(player.Luck, 15))), 0.2) * 100, 15)
							-- local rift = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIFT, 0, entity.Position, Vector.Zero, player):ToEffect()
							-- rift.CollisionDamage = player.Damage / 2
							-- rift:SetTimeout(60)
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_CLOT) then
							-- local increasedDamageChance = OmoriMod.randomNumber(0, 1, rng)
							-- if increasedDamageChance == 1 then
								-- dmg = dmg * 1.1
							-- end
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE) then
							-- local bonesSpawn = OmoriMod.randomNumber(2, 4, rng)
							-- for i = 1, bonesSpawn do
								-- if entity.HitPoints <= dmg then
									-- player:FireTear(entity.Position, RandomVector() * 10, true, true, false, player, 1)
								-- end
							-- end
						-- end	
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) then
							-- local coinSpawnChance = 5
							-- local SpawnChanceRNG = OmoriMod.randomNumber(1, 100, rng)
							-- if SpawnChanceRNG <= coinSpawnChance then
								-- local velocityrandom = OmoriMod.randomfloat(1.5, 3.5, rng)
							
								-- Isaac.Spawn(EntityType.ENTITY_PICKUP, 20, 1, entity.Position, RandomVector() * velocityrandom, nil)
							-- end
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
							-- local technology = player:FireTechLaser(
								-- entity.Position,
								-- 1,
								-- OmoriMod.MakeVector(OmoriMod.randomNumber(1, 360, rng)),
								-- false,
								-- true,
								-- player
							-- ):ToLaser()
							-- technology:SetMaxDistance(player.TearRange / 6)
							-- technology.CollisionDamage = player.Damage
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_BACKSTABBER) then
							-- entity:AddBleeding(EntityRef(player), 150)
						-- end
						-- if player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) then
							-- dmg = dmg * OmoriMod.randomfloat(0.5, 2, rng)
						-- end
						
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_SLOW) then
							-- local SlowColor = Color(0.5, 0.5, 0.5, 1)
							-- entity:AddSlowing(EntityRef(player), 90, 0.6, SlowColor)
						-- end
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_POISON) then
							-- entity:AddPoison(EntityRef(player), 90, player.Damage)
						-- end
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_FREEZE) then
							-- entity:AddFreeze(EntityRef(player), 90)
						-- end
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_EXPLOSIVE) then
							-- local ExplosionColor = Color(1, 1, 1, 1)
							-- Game():BombExplosionEffects(entity.Position, 50, player.TearFlags, ExplosionColor, player, knife.SpriteScale.X/2, LineCheck, DamageSource, DamageFlags)
						-- end
						
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_CHARM) then 
							-- entity:AddCharmed(EntityRef(player), 90)
						-- end
						
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_CONFUSION) then
							-- entity:AddConfusion(EntityRef(player), 90, false)
						-- end
						
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_FEAR) then
							-- entity:AddFear(EntityRef(player), 90)
						-- end 
						
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_SHRINK) then
							-- entity:AddShrink(EntityRef(player), 90)
						-- end 
						
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_KNOCKBACK) then
							-- WEAPON_KNOCKBACK_VELOCITY = WEAPON_KNOCKBACK_VELOCITY * 1.025
						-- end
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_ICE) then
							-- entity:AddEntityFlags(EntityFlag.FLAG_ICE)
						-- end
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_MAGNETIZE) then
							-- entity:AddKnockback(EntityRef(player), entity.Position, 15, false)
						-- end
						-- if OmoriMod:playerHasTearFlag(player, TearFlags.TEAR_BAIT) then
							-- entity:AddBaited(EntityRef(player), 90)
						-- end

						-- local tearEffectsPlaydough = {
							-- [1] = function()
								-- local SlowColor = Color(0.5, 0.5, 0.5, 1)
								-- entity:AddSlowing(EntityRef(player), 90, 0.6, SlowColor)
							-- end,
							-- [2] = function()
								-- entity:AddPoison(EntityRef(player), 90, player.Damage)
							-- end, 
							-- [3] = function()
								-- entity:AddFreeze(EntityRef(player), 90)
							-- end,
							-- [4] = function()
								-- local ExplosionColor = Color(1, 1, 1, 1)
								-- Game():BombExplosionEffects(entity.Position, 50, player.TearFlags, ExplosionColor, player, knife.SpriteScale.X/2, LineCheck, DamageSource, DamageFlags)
							-- end,
							-- [5] = function()
								-- entity:AddCharmed(EntityRef(player), 90)
							-- end,
							-- [6] = function()
								-- entity:AddConfusion(EntityRef(player), 90, false)
							-- end,
							-- [7] = function()
								-- entity:AddFear(EntityRef(player), 90)
							-- end,
							-- [8] = function()
								-- entity:AddShrink(EntityRef(player), 90)
							-- end,
							-- [9] = function()
								-- WEAPON_KNOCKBACK_VELOCITY = WEAPON_KNOCKBACK_VELOCITY * 1.025
							-- end,
							-- [10] = function()
								-- if entity.HitPoints < dmg then
									-- entity:AddEntityFlags(EntityFlag.FLAG_ICE)
								-- end
							-- end,
							-- [11] = function()
								-- entity:AddKnockback(EntityRef(player), entity.Position, 15, false)
							-- end,
							-- [12] = function()
								-- entity:AddBaited(EntityRef(player), 90)
							-- end,
						-- }
						-- for i = 1, totalHits do
							-- local HappyFailChance = OmoriMod.randomNumber(1, 100, rng)
							
							-- if player:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE) then
								-- local randomEffect = OmoriMod.randomNumber(1, 12, rng)
								-- OmoriMod.SwitchCase(randomEffect, tearEffectsPlaydough, true)
							-- end
						
							-- local HappyFailChance = OmoriMod.randomNumber(1, 100, rng)
							-- local happyTier = {
								-- ["Happy"] = 10, 
								-- ["Ecstatic"] = 20, 
								-- ["Manic"] = 30, 
							-- }
							-- local MaxHappyFailChance = OmoriMod.SwitchCase(OmoriMod.GetEmotion(player), happyTier) or 0	
								
							-- if HappyFailChance <= MaxHappyFailChance then
								-- if data.HappyAttack ~= true then
									-- dmg = dmg * 0
								-- end
							-- end
							-- entity:TakeDamage(dmg, 0, EntityRef(player), 0)
						-- end

						-- local pushAngle = (entity.Position - knife.Position):GetAngleDegrees()
						-- entity:AddVelocity(WEAPON_KNOCKBACK_VELOCITY:Rotated(pushAngle))

						-- data.HitBlacklist[GetPtrHash(entity)] = true
						-- sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 1, 0, false, 1, 0)
							
						-- if dmg <= 0 and sfx:IsPlaying(SoundEffect.SOUND_MEATY_DEATHS) then
							-- sfx:Stop(SoundEffect.SOUND_MEATY_DEATHS)
							-- sfx:Play(OmoriMod.Enums.SoundEffect.SOUND_MISS_ATTACK, 2, 0, false, 1, 0)
						-- end

						-- if data.HappyAttack == true then
							-- sfx:Play(OmoriMod.Enums.SoundEffect.SOUND_RIGHT_IN_THE_HEART, 1, 0, false, 1, 0)
						-- end
					-- end
				-- else
					-- local NonEnemyEntities = {
						-- [EntityType.ENTITY_TEAR] = function()
							-- if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
								-- local tear = entity:ToTear()
								-- local tearData = OmoriMod:GetData(tear)

								-- if tearData.HitByKnife == false then
									-- tearData.HitByKnife = true
								-- end
								-- tear.Velocity = ((entity.Position - player.Position):Normalized()):Resized(120)
							-- end
						-- end,
						-- [EntityType.ENTITY_FAMILIAR] = function()
							-- if entity.Variant == FamiliarVariant.PUNCHING_BAG or entity.Variant == FamiliarVariant.CUBE_BABY then
								-- entity.Velocity = (entity.Position - player.Position):Resized(30)
							-- end
						-- end,
						-- [EntityType.ENTITY_BOMB] = function()
							-- entity.Velocity = (entity.Position - player.Position):Resized(30)
						-- end,
						-- [EntityType.ENTITY_FIREPLACE] = function()
							-- local BlacklistedFireplaces = {
								-- 2,
								-- 3,
								-- 4,
								-- 12,
								-- 13
							-- }
							-- for key, value in pairs(BlacklistedFireplaces) do
								-- if entity.Variant == value then
									-- return
								-- else
									-- entity:Kill()
								-- end
							-- end
						-- end,
						-- [EntityType.ENTITY_PICKUP] = function()
							-- local pickup = entity:ToPickup()
							-- local pickupSprite = entity:GetSprite()
							-- local pickupBlackList = {
								-- PickupVariant.PICKUP_COLLECTIBLE,
								-- PickupVariant.PICKUP_BROKEN_SHOVEL,
								-- PickupVariant.PICKUP_TROPHY,
								-- PickupVariant.PICKUP_BED,
								-- PickupVariant.PICKUP_MOMSCHEST,
							-- }
							
							-- for key, value in pairs(pickupBlackList) do
								-- if entity.Variant == value then 
									-- return
								-- else
									-- player:ForceCollide(entity, false)
								-- end
							-- end
						-- end,
						-- [EntityType.ENTITY_PROJECTILE] = function()
							-- local projectile = entity:ToProjectile()
							-- if playerData.SwordSwing and playerData.SwordSwing == true then
								-- projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES | ProjectileFlags.CANT_HIT_PLAYER)
								-- projectile.Damage = player.Damage * 2
								-- entity.Velocity = (entity.Position - player.Position):Resized(20)
							-- end
							-- if player:HasCollectible(CollectibleType.COLLECTIBLE_LOST_CONTACT) then
								-- projectile:Kill()
							-- end
						-- end
					-- }
					
					-- OmoriMod.SwitchCase(entity.Type, NonEnemyEntities)
		
					-- for i = 0, (room:GetGridSize()) do
						-- local gent = room:GetGridEntity(i)
						-- if gent then
							-- if knifesprite:IsPlaying("Swing") then
								-- if (capsulePosition - gent.Position):Length() <= 30 * knife.SpriteScale.X then
									-- local poop = gent:ToPoop()
									-- local rock = gent:ToRock()
									-- local door = gent:ToDoor()
									-- if poop then
										-- poop:Destroy()
									-- elseif rock or door then
										-- if player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) then
											-- gent:Destroy()
										-- end
									-- end
								-- end
							-- end
						-- end
					-- end
				-- end
			-- end
		-- end
	-- end
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ShinyKnife.KnifeEffectUpdate, OmoriMod.Enums.EffectVariant.EFFECT_SHINY_KNIFE)

-- function mod:FakeLudoUpdate(tear)
	-- local tearData = OmoriMod:GetData(tear)
    -- local player = OmoriMod.GetPlayerFromAttack(tear)
    -- local playerData = OmoriMod:GetData(player)

	-- if player then
		-- if OmoriMod:IsKnifeUser(player) then
			-- if tearData.IsFakeLudoTear and tearData.IsFakeLudoTear == true then
				-- tear.Height = -23
				
				-- local damageDiv = 3.5
				-- if player:GetPlayerType() == OmoriMod.Enums.PlayerType.PLAYER_OMORI then
					-- damageDiv = 2.8
				-- end
				
				-- multScale = math.max((player.Damage / damageDiv), 1)
				
				-- tear.Scale = 1.85 * multScale
				-- tear:AddTearFlags(player.TearFlags | TearFlags.TEAR_BOUNCE)
				
				-- tearData.HitByKnife = tearData.HitByKnife or false
				
				-- if tearData.HitByKnife and tearData.HitByKnife == true then
					-- local damageCap = math.min(player.Damage * 12, player.Damage * OmoriMod:GetAceleration(tear)) 
					-- tear.CollisionDamage = damageCap
					
					-- if OmoriMod:GetAceleration(tear) >= 0 and OmoriMod:GetAceleration(tear) < 2 then
						-- tearData.HitByKnife = false
					-- end
					-- tear:MultiplyFriction(0.975)
				-- else
					-- tear:MultiplyFriction(0.7)
					-- tear.Velocity = tear.Velocity + (((player.Position - tear.Position):Normalized() * (player.Position - tear.Position):Length() / 40)) 
					
					-- tear.CollisionDamage = player.Damage
					
					-- local distance = tear.Position:Distance(player.Position)
					
					-- local carajo = 0.7 * (distance / 65)
					
					-- if distance <= 65 then
						-- tear:MultiplyFriction(math.min(carajo, 0.95))
					-- end
				-- end
				
				-- OmoriMod.DoHappyTear(tear)
			-- end
		-- end
	-- end
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.FakeLudoUpdate)

-- function mod:GodTearUpdate(tear)
    -- local tearData = OmoriMod:GetData(tear)
    -- local player = OmoriMod.GetPlayerFromAttack(tear)
    -- local playerData = OmoriMod:GetData(player)
	
	-- if player then
		-- local shoot = {
			-- l = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
			-- r = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
			-- u = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
			-- d = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
		-- }

		-- tearData.TearLastPos = tear.Position

		-- local isShooting = (shoot.l or shoot.r or shoot.u or shoot.d)
		-- if OmoriMod:IsKnifeUser(player) then
			-- if tearData.TearFromKnife ~= nil then
				-- for _, knife in pairs(Isaac.GetRoomEntities()) do
					-- if knife.Type == EntityType.ENTITY_EFFECT and knife.Variant == EffectVariant.EFFECT_SHINY_KNIFE then
						-- local knifesprite = knife:GetSprite()
						-- if knifesprite:IsPlaying("Swing") then
							-- tear.Position = player.Position + playerData.Aiming:Resized(30 * knife.SpriteScale.X)
							-- tear.Height = -23
						-- else
							-- tear:Remove()
						-- end
					-- end
				-- end
			-- end
		-- end
	-- end
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.GodTearUpdate)

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