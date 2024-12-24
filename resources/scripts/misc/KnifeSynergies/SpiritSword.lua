local mod = OmoriMod
local enums = mod.Enums
local Callbacks = enums.Callbacks

---@param player EntityPlayer
---@return boolean
local function hasSword(player) 
    return player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
end

---comment
---@param knife EntityEffect
---@return boolean?
function mod:SwordSwing(knife)
    local player = OmoriMod:GetKnifeOwner(knife)

    local knifeData = OmoriMod:GetData(knife)

    if not player then return end
    local playerData = OmoriMod:GetData(player)

    if not hasSword(player) then return end

    knifeData.SwordSwing = knifeData.SwordSwing or false

    if playerData.shinyKnifeCharge >= 10 then return end 

    if OmoriMod:IsShootTriggered(player) then
        OmoriMod:InitKnifeSwing(knife)
        knifeData.AllowOriginalLogic = false
        knifeData.SwordSwing = true
    end
end
mod:AddCallback(Callbacks.POST_KNIFE_RENDER, mod.SwordSwing)

function mod:FullChargeAttack(knife, _, damage)
    local player = OmoriMod:GetKnifeOwner(knife)
    local knifeData = OmoriMod:GetData(knife)

    if not player then return end
    local playerData = OmoriMod:GetData(player)

    if not hasSword(player) then return end

    if playerData.shinyKnifeCharge ~= 100 then return end

    knifeData.Damage = knifeData.Damage * 1.5
end
mod:AddCallback(Callbacks.KNIFE_HIT_ENEMY, mod.FullChargeAttack)

function mod:OnSwordFullSwinging(knife)
    local player = knife.SpawnerEntity:ToPlayer()

    if not player then return end
    local playerData = OmoriMod:GetData(player)

    if not hasSword(player) then return end

    if playerData.shinyKnifeCharge ~= 100 then return end

    OmoriMod:SetKnifeSizeMult(knife, 1.5)
end
mod:AddCallback(Callbacks.KNIFE_SWING, mod.OnSwordFullSwinging)