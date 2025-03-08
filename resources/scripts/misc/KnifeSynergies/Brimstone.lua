local mod = OmoriMod
local enums = mod.Enums
local Callbacks = enums.Callbacks

function mod:BrimstoneKnifeSynergy(knife)
    local player = OmoriMod:GetKnifeOwner(knife)
    local playerData = OmoriMod.GetData(player)

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then return end
    if playerData.shinyKnifeCharge ~= 100 then return end

    player:FireBrimstoneBall(player.Position, Vector.FromAngle(knife.SpriteRotation) * 5, Vector.Zero)
end
mod:AddCallback(Callbacks.KNIFE_SWING_TRIGGER, mod.BrimstoneKnifeSynergy)