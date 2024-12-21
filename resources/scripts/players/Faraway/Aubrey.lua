local mod = OmoriMod
local enums = mod.Enums
local tables = enums.Tables
local costumes = enums.NullItemID
local callbacks = enums.Callbacks
local utils = enums.Utils
local game = utils.Game
local room = game:GetRoom()
local sfx = utils.SFX
local sounds = enums.SoundEffect
local misc = enums.Misc
local rng = utils.RNG


---comment
---@param player EntityPlayer
function mod:InitFarawayAubrey(player)
    if not OmoriMod:IsAubrey(player, true) then return end

    local playerData = OmoriMod:GetData(player)
    
    player:AddNullCostume(costumes.ID_RW_AUBREY)
    player:AddNullCostume(costumes.ID_EMOTION)

    playerData.HeadButtCooldown = OmoriMod:SecsToFrames(5)
    playerData.EmotionCounter = OmoriMod:SecsToFrames(7)
    playerData.HeadButt = false

    OmoriMod.SetEmotion(player, "Neutral")
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.InitFarawayAubrey)

---comment
---@param player EntityPlayer
function mod:FarawayAubreyUpdate(player)
    if not OmoriMod:IsAubrey(player, true) then return end

    OmoriMod:GiveKnife(player)

    if player:CollidesWithGrid() then
        OmoriMod:TriggerHBParams(player)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.FarawayAubreyUpdate)

---comment
---@param knife EntityEffect
---@return number
function mod:AubreyBatCharge(knife)
    local player = knife.SpawnerEntity:ToPlayer()
    if not player then return end

    if not OmoriMod:IsAubrey(player, true) then return end

    local batCharge = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 1.5 or 2

    return OmoriMod:SecsToKnifeCharge(batCharge)
end
mod:AddCallback(callbacks.PRE_KNIFE_CHARGE, mod.AubreyBatCharge)

local emotionToSet = {
    ["Neutral"] = "Angry",
    ["Angry"] = "Enraged"
}

---comment
---@param entity Entity
local function DisplayData(entity)
    local data = OmoriMod:GetData(entity)

    print("=====================")
    for k, v in pairs(data) do
        print(k, v)
    end
end

---comment
---@param player EntityPlayer
function mod:FarawayAubreyEffectUpdate(player)
    local emotion = OmoriMod.GetEmotion(player)
    local playerData = OmoriMod:GetData(player)

    if not OmoriMod:IsAubrey(player, true) then return end

    -- DisplayData(player)

    if room:IsClear() then
        playerData.EmotionCounter = OmoriMod:SecsToFrames(5)
        playerData.HeadButtCooldown = OmoriMod:SecsToFrames(3)
        return
    end

    if emotion == "Angry" or emotion == "Enraged" then
        playerData.HeadButtCooldown = math.max(playerData.HeadButtCooldown - 1, 0)

        if playerData.HeadButtCooldown == 0 then
            
            OmoriMod:InitHeadbutt(player)
            playerData.HeadButtCooldown = OmoriMod:SecsToFrames(3)
        end

        if playerData.HeadButtCooldown <= 30 and playerData.HeadButtCooldown > 0 and playerData.HeadButtCooldown % 10 == 0 then
            player:SetColor(misc.ReadyColor, 5, -1, true, true)
            sfx:Play(sounds.SOUND_HEADBUTT_START)
        end
    end

    if emotion ~= "Enraged" then
        playerData.EmotionCounter = math.max(playerData.EmotionCounter - 1, 0)
        if playerData.EmotionCounter == 0 then
            playerData.EmotionCounter = OmoriMod:SecsToFrames(5)
            OmoriMod.SetEmotion(player, emotionToSet[emotion] or "Angry")
        end

        if playerData.EmotionCounter <= 30 and playerData.EmotionCounter > 0 and playerData.EmotionCounter % 10 == 0 then
            player:SetColor(misc.AngryColor, 5, -1, true, true)
            sfx:Play(SoundEffect.SOUND_BEEP)
        end
    end

    if playerData.HeadButt then
        player.Velocity = playerData.FixedDir:Resized(12)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.FarawayAubreyEffectUpdate)

local HBParams = tables.AubreyHeadButtParams

---comment
---@param player EntityPlayer
---@param collider Entity
function mod:OnFarawayAubreyCollide(player, collider)
    local playerData = OmoriMod:GetData(player)

    if not OmoriMod:IsAubrey(player, true) then return end

    if playerData.HeadButt == false then return end
    
    local isEnemy = collider:IsActiveEnemy() and collider:IsVulnerableEnemy()

    if not isEnemy then return end

    local emotion = OmoriMod.GetEmotion(player)

    sfx:Play(sounds.SOUND_HEADBUTT_HIT)
    local DamageFormula = (player.Damage * 2) * math.max(player.MoveSpeed, 1) * HBParams[emotion].DamageMult

    for _, entity in ipairs(Isaac.FindInRadius(player.Position, 60, EntityPartition.ENEMY)) do
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

    mod:TriggerHBParams(player)
    collider.Velocity = (collider.Position - player.Position)

    OmoriMod.SetEmotion(player, "Neutral")
    playerData.EmotionCounter = OmoriMod:SecsToFrames(5)
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, mod.OnFarawayAubreyCollide)

---comment
---@param bat EntityEffect
---@param entity Entity
---@return number?
function mod:NailbatHit(bat, entity)
    local player = bat.SpawnerEntity:ToPlayer()

    if not player then return end
    if not OmoriMod:IsAubrey(player, true) then return end

    local homeRunChance = OmoriMod.randomNumber(1, 100, rng)

    if homeRunChance <= 10 then
        return math.huge
    end
end
mod:AddCallback(callbacks.KNIFE_HIT_ENEMY, mod.NailbatHit)