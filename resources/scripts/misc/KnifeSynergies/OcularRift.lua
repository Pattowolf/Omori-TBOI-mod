local mod = OmoriMod
local enums = mod.Enums
local utils = enums.Utils
local rng = utils.RNG
local Callbacks = enums.Callbacks

---@param knife EntityEffect
---@param entity EntityNPC
function mod:MomsKnifeDamage(knife, entity)
    local player = OmoriMod:GetKnifeOwner(knife)
    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_OCULAR_RIFT) then return end
    
    local SpawnRiftChance = OmoriMod.randomNumber(1, 100, rng)
    local maxChance = math.min(math.min(1 / (20 - (math.min(player.Luck, 15))), 0.2) * 100, 15)
    local rift = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIFT, 0, entity.Position, Vector.Zero, 
    player):ToEffect()
    
    if not rift then return end
    
    if SpawnRiftChance <= maxChance then
        rift.CollisionDamage = player.Damage / 2
        rift:SetTimeout(60)
    end
end
mod:AddCallback(Callbacks.KNIFE_HIT_ENEMY, mod.MomsKnifeDamage)