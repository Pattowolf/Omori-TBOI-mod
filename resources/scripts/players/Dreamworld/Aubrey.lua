local mod = OmoriMod
local enums = OmoriMod.Enums
local utils = enums.Utils
local costumes = enums.NullItemID
local sfx = utils.SFX
local sounds = enums.SoundEffect
local game = utils.Game
local rng = utils.RNG
local tables = enums.Tables
local HBParams = tables.AubreyHeadButtParams
local Callbacks = enums.Callbacks

local HeadButtAOE = 60
local NeutralColor = Color(1, 1, 1, 1, 0.2, 0.2, 0.2)

---comment
---@param player EntityPlayer
function mod:InitAubrey(player)
    if not OmoriMod:IsAubrey(player, false) then return end
    player:AddNullCostume(costumes.ID_DW_AUBREY)
    player:AddNullCostume(costumes.ID_EMOTION)

    local playerData = OmoriMod:GetData(player)

    playerData.HeadButt = false
    playerData.FixedDir = nil
    playerData.HeadButtCounter = 0
    playerData.EmotionCounter = 0

    OmoriMod.SetEmotion(player, "Neutral")
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.InitAubrey)

function mod:AubreyStats(player, flags)
    if not OmoriMod:IsAubrey(player, false) then return end

    if flags == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage * 1.3
    elseif flags == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = OmoriMod.tearsUp(player.MaxFireDelay, 0.75, true)
    elseif flags == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed * 0.8
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.AubreyStats)

---@param player EntityPlayer
function mod:AubreyInputs(player)
    if not OmoriMod:IsAubrey(player, false) then return end
    local playerData = OmoriMod:GetData(player) ---@type table

    if playerData.HeadButtCounter ~= 0 then return end

    if OmoriMod:IsEmotionChangeTriggered(player) then 
        if not OmoriMod:IsPlayerMoving(player) then return end
        
        mod:InitHeadbutt(player)
    end

    if player:CollidesWithGrid() then
        if playerData.HeadButt == true then
            mod:TriggerHBParams(player, true, true)
            game:ShakeScreen(10)

            sfx:Play(sounds.SOUND_HEADBUTT_KILL)

            player:SetMinDamageCooldown(40)
        end       
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.AubreyInputs)

---comment
---@param player EntityPlayer
function mod:AubreyButthead(player)
    if not OmoriMod:IsAubrey(player, false) then return end

    local playerData = OmoriMod:GetData(player) ---@type table

    if not playerData.HeadButt then
        local counters = {
            HeadButtCounter = "HeadButt",
            EmotionCounter = "Emotion"
        }

        for counterName, _ in pairs(counters) do
            if playerData[counterName] > 0 then
                playerData[counterName] = playerData[counterName] - 1
            
                if counterName == "HeadButtCounter" and playerData[counterName] == 1 then
                    sfx:Play(sounds.SOUND_HEART_HEAL)
                    player:SetColor(Color(0.7, 1, 0.2, 1), 5, -1, true, true)
                end
            
                if counterName == "EmotionCounter" then
                    if OmoriMod.GetEmotion(player) ~= "Neutral" then
                        if playerData[counterName] <= 30 and playerData[counterName] % 10 == 0 then
                            player:SetColor(NeutralColor, 8, -1, true, true)
                            if playerData[counterName] > 0 then
                                sfx:Play(SoundEffect.SOUND_BEEP)
                            else
                                OmoriMod.SetEmotion(player, "Neutral")
                            end
                        end
                    end
                end
            end
        end
    else
        player.Velocity = playerData.HeadButtDir
    end     
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.AubreyButthead)

---@param player EntityPlayer
---@param collider Entity
---@return boolean?
function mod:AubreyHittingButthead(player, collider)
    local playerData = OmoriMod:GetData(player)
    local emotion = OmoriMod.GetEmotion(player)

    if not OmoriMod:IsAubrey(player, false) then return end

    if not (collider:IsActiveEnemy() and collider:IsVulnerableEnemy()) then return end

    if playerData.HeadButt == false then return end

    sfx:Play(sounds.SOUND_HEADBUTT_HIT)
    local DamageFormula = (player.Damage * 2) * math.max(player.MoveSpeed, 1) * HBParams[emotion].DamageMult

    playerData.EmotionCounter = math.max(playerData.EmotionCounter - 5, 0)

    collider:TakeDamage(DamageFormula, 0, EntityRef(player), 0)

    for _, entity in ipairs(Isaac.FindInRadius(player.Position, HeadButtAOE, EntityPartition.ENEMY)) do
        entity:TakeDamage(DamageFormula * 0.8, 0, EntityRef(player), 0)
        collider.Velocity = (collider.Position - player.Position) * 1.5
    end

    mod:TriggerHBParams(player, false, false)

    player:SetMinDamageCooldown(20)

    collider.Velocity = (collider.Position - player.Position)
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, mod.AubreyHittingButthead)

---comment
---@param entity Entity
---@param source EntityRef
---@return boolean?
function mod:NullHeadbuttDamage(entity, _, _, source)
    local player = entity:ToPlayer()    

    if not player then return end

    if not OmoriMod:IsAubrey(player, false) then return end

    local playerData = OmoriMod:GetData(player)

    if playerData.HeadButt == true then
        return false
    else
        local emotionChangeTrigger = OmoriMod.randomNumber(1, 100, rng)
        local emotion = OmoriMod.GetEmotion(player)

        if emotionChangeTrigger <= 20 then
            OmoriMod.SetEmotion(player, HBParams[emotion].Emotion)
            playerData.EmotionCounter = HBParams[emotion].EmotionCooldown
        end
    end

    local ent = source.Entity
    local enemy = ent:IsActiveEnemy() and ent:IsVulnerableEnemy()

    if ent and enemy then
        if ent.Type == 0 then return end

        local MrEggplant = OmoriMod:GiveKnife(player)

        if not MrEggplant then return end

        local MrESprite = MrEggplant:GetSprite()
        local MrEData = OmoriMod:GetData(MrEggplant)

        local playerPos = player.Position
        local entPos = ent.Position

        MrEData.Aiming = (entPos - playerPos):GetAngleDegrees()

        MrESprite:Play("Swing")
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.NullHeadbuttDamage)

function mod:OnAubreyNewRoom()
    local players = PlayerManager.GetPlayers()

    for _, player in ipairs(players) do
        local playerData = OmoriMod:GetData(player)

        if playerData.HeadButt then
            playerData.HeadButt = false
            playerData.FixedDir = nil
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.OnAubreyNewRoom)

function mod:MrEggplantBehavior(knife)
    local player = knife.SpawnerEntity:ToPlayer()
    if not OmoriMod:IsAubrey(player, false) then return end
    
    local playerData = OmoriMod:GetData(player)

    local sprite = knife:GetSprite()

    if sprite:IsFinished("Swing") then
        knife:Remove()
        playerData.ShinyKnife = nil
    end
end
mod:AddCallback(Callbacks.PRE_KNIFE_UPDATE, mod.MrEggplantBehavior)

local healChance = {
    ["Neutral"] = {HealMaxRoll = 20, hearts = 2},
    ["Angry"] = {HealMaxRoll = 15, hearts = 3},
    ["Enraged"] = {HealMaxRoll = 15, hearts = 3},
}

---comment
---@param Eggplant EntityEffect
function mod:OnMrEggplantKill(Eggplant)
    local player = Eggplant.SpawnerEntity:ToPlayer()
    
    if not player then return end 

    if not OmoriMod:IsAubrey(player, false) then return end

    local emotion = OmoriMod.GetEmotion(player)

    local healMaxChance = healChance[emotion].HealMaxRoll
    local healRoll = OmoriMod.randomNumber(1, 100, rng)

    if healRoll <= healMaxChance then
        player:AddHearts(healChance[emotion].hearts)
    end
end
mod:AddCallback(Callbacks.KNIFE_KILL_ENEMY, mod.OnMrEggplantKill)

