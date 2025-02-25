local mod = OmoriMod
local enums = mod.Enums
local utils = enums.Utils
local costumes = enums.NullItemID
local sfx = utils.SFX
local sounds = enums.SoundEffect
local game = utils.Game
local rng = utils.RNG
local tables = enums.Tables
local HBParams = tables.AubreyHeadButtParams
local Callbacks = enums.Callbacks
local misc = enums.Misc
local knifeType = enums.KnifeType

local HeadButtAOE = 60
local NeutralColor = Color(1, 1, 1, 1, 0.2, 0.2, 0.2)

local function thereAreEnemies()
    local bool = false
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
            bool = true
        end
    end
    return bool
end

---comment
---@param player EntityPlayer
function mod:InitAubrey(player)
    if not OmoriMod.IsAubrey(player, false) then return end
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
    if not OmoriMod.IsAubrey(player, false) then return end

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
    if not OmoriMod.IsAubrey(player, false) then return end
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
    player.Size = (playerData.HeadButt == true and thereAreEnemies()) and 20 or 10
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.AubreyInputs)

---comment
---@param player EntityPlayer
function mod:AubreyButthead(player)
    if not OmoriMod.IsAubrey(player, false) then return end
    local playerData = OmoriMod:GetData(player) ---@type table
    local room = game:GetRoom()

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
                    player:SetColor(misc.ReadyColor, 5, -1, true, true)
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
        if room:GetType() ~= RoomType.ROOM_DUNGEON then
            player.Velocity = playerData.HeadButtDir
        else
            if OmoriMod:GetAceleration(player) < 1 then
                if playerData.HeadButt == true then
                    playerData.HeadButt = false
                end
            end
        end
    end     

    if player:GetDamageCooldown() == 0 then
        playerData.TriggerMrEggplant = true
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.AubreyButthead)

---@param player EntityPlayer
---@param collider Entity
---@return boolean?
function mod:AubreyHittingButthead(player, collider)
    local playerData = OmoriMod:GetData(player)
    local emotion = OmoriMod.GetEmotion(player)

    if not OmoriMod.IsAubrey(player, false) then return end
    if not (collider:IsActiveEnemy() and collider:IsVulnerableEnemy()) then return end
    if playerData.HeadButt == false then return end

    sfx:Play(sounds.SOUND_HEADBUTT_HIT)
    local DamageFormula = (player.Damage * 2) * math.max(player.MoveSpeed, 1) * HBParams[emotion].DamageMult

    if collider:IsBoss() then
        player:SetMinDamageCooldown(30)
    end

    for _, entity in ipairs(Isaac.FindInRadius(player.Position, HeadButtAOE, EntityPartition.ENEMY)) do
        entity:TakeDamage(DamageFormula, 0, EntityRef(player), 0)
        collider.Velocity = (collider.Position - player.Position) * 1.5
 
        if entity.HitPoints <= DamageFormula then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                player:AddHearts(1)
            end
            player:SetMinDamageCooldown(20)
        else
            playerData.TriggerMrEggplant = false
        end
    end

    mod:TriggerHBParams(player, false, false)
    collider.Velocity = (collider.Position - player.Position)
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, mod.AubreyHittingButthead)

---comment
---@param entity Entity
---@param source EntityRef
---@param flags DamageFlag
---@return boolean?
function mod:NullHeadbuttDamage(entity, _, flags, source)
    local player = entity:ToPlayer()    

    if not player then return end
    if not OmoriMod.IsAubrey(player, false) then return end

    local playerData = OmoriMod:GetData(player)
    local emotion = OmoriMod.GetEmotion(player)
    local emotionChangeTrigger = OmoriMod.randomNumber(1, 100, rng)
    local SpikeAcidFlags = DamageFlag.DAMAGE_ACID | DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_CURSED_DOOR

    if playerData.HeadButt then
        if OmoriMod:isFlagInBitmask(flags, SpikeAcidFlags) then
            return false
        end 
    end

    if source.Type == 0 then return end

    local ent = source.Entity

    if not ent then return end
    if ent.Type == 0 then return end

    local enemy = ent:IsActiveEnemy() and ent:IsVulnerableEnemy()

    if enemy then
        if emotionChangeTrigger <= 20 then
            OmoriMod.SetEmotion(player, HBParams[emotion].Emotion)
            playerData.EmotionCounter = HBParams[emotion].EmotionCooldown
        end
    else
        if playerData.HeadButt == true then
            return false
        end
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
    if not OmoriMod.IsAubrey(player, false) then return end
    local playerData = OmoriMod:GetData(player)
    local sprite = knife:GetSprite()

    if sprite:IsFinished("Swing") then
        OmoriMod.RemoveKnife(player, knifeType.MR_PLANT_EGG)
    end
end
mod:AddCallback(Callbacks.PRE_KNIFE_UPDATE, mod.MrEggplantBehavior)

local healChance = {
    ["Neutral"] = 30,
    ["Angry"] = 35,
    ["Enraged"] = 45,
}

---@param Eggplant EntityEffect
function mod:OnMrEggplantKill(Eggplant)
    local player = Eggplant.SpawnerEntity:ToPlayer() ---@type EntityPlayer?
    if not player then return end 
    if not OmoriMod.IsAubrey(player, false) then return end

    local emotion = OmoriMod.GetEmotion(player)
    local maxChance = healChance[emotion]

    if healChance[emotion] == nil then
        maxChance = 30
    end

    local birthrightMult = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 1.5 or 1
    local healMaxChance = math.ceil(maxChance * birthrightMult)
    local healRoll = OmoriMod.randomNumber(1, 100, rng)

    if healRoll <= healMaxChance then
        player:AddHearts(2)
    end
end
mod:AddCallback(Callbacks.KNIFE_KILL_ENEMY, mod.OnMrEggplantKill)