local mod = OmoriMod
local enums = mod.Enums
local utils = enums.Utils
local rng = utils.RNG
local Callbacks = enums.Callbacks

function mod:KnifeHolyLightHit(knife, entity, damage)
    local player = OmoriMod:GetKnifeOwner(knife)

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) then return end

    local castLightChance = OmoriMod.randomfloat(0, 1, rng)
    local maxChance = math.min(1 / (10 - (player.Luck * 0.9)), 0.5)
        
    if player.Luck > 11 then	
        maxChance = 0.5
    end

    if castLightChance <= maxChance then
        local light = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 10, entity.Position, Vector.Zero, player):ToEffect()

        if not light then return end
        entity:TakeDamage(damage * 3, DamageFlag.DAMAGE_LASER, EntityRef(player), 0)
    end
end
mod:AddCallback(Callbacks.KNIFE_HIT_ENEMY, mod.KnifeHolyLightHit)
