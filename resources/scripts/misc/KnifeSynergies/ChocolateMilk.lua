local mod = OmoriMod
local enums = mod.Enums
local utils = enums.Utils
local rng = utils.RNG
local Callbacks = enums.Callbacks

function OmoriMod:GetTPS(p)
    return (30 / (p.MaxFireDelay + 1))
end

local function GetNeptunusCharge(player)
    local weapon = player:GetWeapon(1)
    if not weapon then return end
    
    local weaponMod = weapon:GetModifiers()
        
    if weaponMod & weaponMod == WeaponModifier.NEPTUNUS ~= true then return end
    local weaponFireDelay = weapon:GetMaxFireDelay()
    
    local maxFireDelay = weapon:GetMaxFireDelay()
    local maxNepCharge = math.max(11 + 12 * maxFireDelay ,2) -- Thanks roary (taken from neptunus synergies)

    local charge = weapon:GetCharge()
    
    local rawNepCharge = (charge / maxNepCharge) 
    local NepCharge = (rawNepCharge)

    return NepCharge
end

function mod:GetWeaponCharge(player)
    local weapon = player:GetWeapon(1)

    local playerData = OmoriMod:GetData(player)

    if not weapon then return end

    local weaponMod = weapon:GetModifiers()

    if not OmoriMod:isFlagInBitmask(weaponMod, WeaponModifier.CHOCOLATE_MILK) then return end

    local baseMaxCharge = 26.5

    local chargeFactor = (2.7272727272727 / OmoriMod:GetTPS(player)) -- it's not exact but it works 

    local charge = weapon:GetCharge()

    if charge ~= 0 then
        playerData.ChoccyCharge = OmoriMod:Round (charge / (chargeFactor * baseMaxCharge), 2)
    end

    playerData.shinyKnifeCharge = (playerData.ChoccyCharge * 100)

    print(playerData.shinyKnifeCharge)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.GetWeaponCharge)

---comment
---@param knife EntityEffect
---@param damage number
function mod:ChocolateDamage(knife, _, damage)
    local player = OmoriMod:GetKnifeOwner(knife)
    if not player then return end
    local weapon = player:GetWeapon(1)
    if not weapon then return end

    local playerData = OmoriMod:GetData(player)
    local weaponMod = weapon:GetModifiers()

    if not OmoriMod:isFlagInBitmask(weaponMod, WeaponModifier.CHOCOLATE_MILK) then return end

    -- print(playerData.ChoccyCharge)
end
mod:AddCallback(Callbacks.KNIFE_HIT_ENEMY, mod.ChocolateDamage)