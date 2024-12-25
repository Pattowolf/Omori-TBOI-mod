local mod = OmoriMod
local enums = mod.Enums
local utils = enums.Utils
local game = utils.Game
local Callbacks = enums.Callbacks

local function HasBombItem(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) or player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
end

function mod:BombKnifeHit(knife, entity)
    local player = OmoriMod:GetKnifeOwner(knife)

    if not player  then return end
    if not HasBombItem(player) then return end

    game:BombExplosionEffects(
        entity.Position,
        player.Damage * 5,
        player.TearFlags,
        Color.Default,
        player,
        1,
        true,
        false,
        nil
    )
    
end
mod:AddCallback(Callbacks.KNIFE_HIT_ENEMY, mod.BombKnifeHit)