local mod = OmoriMod
local enums = mod.Enums
local utils = enums.Utils
local sounds = enums.SoundEffect
local callbacks = enums.Callbacks
local rng = utils.RNG
local sfx = utils.SFX
local items = enums.CollectibleType
local knifeType = enums.KnifeType

---comment
---@param bat EntityEffect
---@param entity Entity
---@return number?
function mod:NailbatHit(bat, entity)
    local player = bat.SpawnerEntity:ToPlayer()
    if not player then return end

    sfx:Play(sounds.SOUND_AUBREY_HIT, 1, 2, false, 1, 0)

    local homeRunChance = OmoriMod.randomNumber(1, 100, rng)
    local maxChance = entity:IsBoss() == true and 2 or 10

    if homeRunChance <= maxChance then
        return math.huge
    end
    
    OmoriMod:TriggerPush(entity, player, 20)
end
mod:AddCallback(callbacks.KNIFE_HIT_ENEMY, mod.NailbatHit)

function mod:BatSwingTrigger(bat)
    local player = bat.SpawnerEntity:ToPlayer()

    if not player then return end

    sfx:Play(sounds.SOUND_AUBREY_SWING, 0.7, 2, false, 1.5, 0)
end
mod:AddCallback(callbacks.KNIFE_SWING_TRIGGER, mod.BatSwingTrigger)

function mod:OnKnifeRemoving()
	local players = PlayerManager.GetPlayers()
	for _, player in ipairs(players) do
        if not (player:HasCollectible(items.COLLECTIBLE_NAIL_BAT) or mod.IsAubrey(player, true)) then return end

		OmoriMod.RemoveKnife(player, knifeType.NAIL_BAT)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.OnKnifeRemoving)

---comment
---@param player EntityPlayer
function mod:GiveNailBat(player)
    if not (player:HasCollectible(items.COLLECTIBLE_NAIL_BAT) or mod.IsAubrey(player, true)) then return end
    mod.GiveKnife(player, knifeType.NAIL_BAT)
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.GiveNailBat)