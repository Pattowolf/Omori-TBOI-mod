local mod = OmoriMod
local enums = mod.Enums
local utils = enums.Utils
local rng = utils.RNG
local Callbacks = enums.Callbacks

function mod:TechnologyHit(knife, entity)
    local player = OmoriMod:GetKnifeOwner(knife)

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) then return end
	
    local coinSpawnChance = 5
	local SpawnChanceRNG = OmoriMod.randomNumber(1, 100, rng)

	if SpawnChanceRNG > coinSpawnChance then return end
	
	local velocityrandom = OmoriMod.randomfloat(1.5, 3.5, rng)						
	Isaac.Spawn(EntityType.ENTITY_PICKUP, 20, 1, entity.Position, RandomVector() * velocityrandom, nil)
end
mod:AddCallback(Callbacks.KNIFE_HIT_ENEMY, mod.TechnologyHit)
