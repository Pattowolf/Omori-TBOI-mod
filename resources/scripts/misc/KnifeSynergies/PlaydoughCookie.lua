local mod = OmoriMod
local enums = mod.Enums
local utils = enums.Utils
local rng = utils.RNG
local Callbacks = enums.Callbacks

---comment
---@param knife EntityEffect
---@param entity Entity
function mod:PlaydoughKnifeHit(knife, entity)
    local player = OmoriMod:GetKnifeOwner(knife)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE) then return end

    local randSelect = OmoriMod.randomNumber(1, 12, rng)

    local randomEffects = {
        [1] = function()
            local SlowColor = Color(0.5, 0.5, 0.5, 1)
            entity:AddSlowing(EntityRef(player), 90, 0.6, SlowColor)
        end,
        [2] = function()
            entity:AddPoison(EntityRef(player), 90, player.Damage)
        end, 
        [3] = function()
            entity:AddFreeze(EntityRef(player), 90)
        end,
        [4] = function()
            local ExplosionColor = Color(1, 1, 1, 1)
            Game():BombExplosionEffects(entity.Position, 50, player.TearFlags, ExplosionColor, player, knife.SpriteScale.X/2, true, false, 0)
        end,
        [5] = function()
            entity:AddCharmed(EntityRef(player), 90)
        end,
        [6] = function()
            entity:AddConfusion(EntityRef(player), 90, false)
        end,
        [7] = function()
            entity:AddFear(EntityRef(player), 90)
        end,
        [8] = function()
            entity:AddShrink(EntityRef(player), 90)
        end,
        [9] = function()
            entity:AddBurn(EntityRef(player), 150, player.Damage)
        end,
        [10] = function()
            entity:AddEntityFlags(EntityFlag.FLAG_ICE)
        end,
        [11] = function()
            entity:AddKnockback(EntityRef(player), (entity.Position - player.Position):Resized(20), 15, false)
        end,
        [12] = function()
            entity:AddBaited(EntityRef(player), 90)
        end,
	}
    OmoriMod.WhenEval(randSelect, randomEffects)
end
mod:AddCallback(Callbacks.KNIFE_HIT_ENEMY, mod.PlaydoughKnifeHit)