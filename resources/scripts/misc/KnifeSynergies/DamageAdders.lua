local mod = OmoriMod
local enums = mod.Enums
local utils = enums.Utils
local rng = utils.RNG
local Callbacks = enums.Callbacks

function mod:KnifeDamageAdders(knife, _, damage)
    local player = OmoriMod:GetKnifeOwner(knife)
    local knifeData = OmoriMod:GetData(knife)
   
    local adders = {
        [CollectibleType.COLLECTIBLE_APPLE] = function()
            local AppleChance = OmoriMod.randomfloat(0.01, 1, rng)
            local maxChance = math.min(1 / (15 - player.Luck), 1)
            if AppleChance <= maxChance then
                knifeData.Damage = damage * 4
            end
        end,
        [CollectibleType.COLLECTIBLE_TOUGH_LOVE] = function()
            local ToughLoveChance = OmoriMod.randomNumber(1, 100, rng)
            local maxChance = math.min(10 + (player.Luck * 10), 100)
            if ToughLoveChance <= maxChance then
                knifeData.Damage = damage * 3.2
            end
        end,
        [CollectibleType.COLLECTIBLE_STYE] = function()
            local StyeChance = OmoriMod.randomNumber(0, 1, rng)
            if StyeChance == 1 then
                knifeData.Damage = damage * 1.28
            end
        end,
        [CollectibleType.COLLECTIBLE_BLOOD_CLOT] = function()
            local increasedDamageChance = OmoriMod.randomNumber(0, 1, rng)
			if increasedDamageChance == 1 then
			    knifeData.Damage = damage * 1.1
			end
        end,
    }

    for item, funct in pairs(adders) do
        if player:HasCollectible(item) then
            funct()
        end
    end
end
mod:AddCallback(Callbacks.KNIFE_HIT_ENEMY, mod.KnifeDamageAdders)