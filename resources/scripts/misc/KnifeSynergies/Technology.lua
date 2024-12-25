local mod = OmoriMod
local enums = mod.Enums
local Callbacks = enums.Callbacks

function mod:TechnologyHit(knife, entity)
    local player = OmoriMod:GetKnifeOwner(knife)

    if not player then return end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then return end
        local technology = player:FireTechLaser(
            entity.Position,
            1,
            (entity.Position - player.Position),
            false,
            true,
            player
        ):ToLaser()

        if not technology then return end

        technology:SetMaxDistance(player.TearRange / 3)
        technology.CollisionDamage = player.Damage
end
mod:AddCallback(Callbacks.KNIFE_HIT_ENEMY, mod.TechnologyHit)
