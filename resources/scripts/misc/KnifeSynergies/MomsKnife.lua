local mod = OmoriMod
local enums = mod.Enums
local utils = enums.Utils
local rng = utils.RNG
local Callbacks = enums.Callbacks

---comment
---@param knife EntityEffect
---@param _ any
---@param damage number
function mod:MomsKnifeDamage(knife, _, damage)
    local player = OmoriMod:GetKnifeOwner(knife)
    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then return end
    local knifeData = OmoriMod.GetData(knife)

    knifeData.Damage = knifeData.Damage * 0.75
end
mod:AddCallback(Callbacks.KNIFE_HIT_ENEMY, mod.MomsKnifeDamage)